import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/riverpod_providers.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_file.dart';
import '../../domain/usecases/get_workspace_files.dart';
import '../../domain/usecases/pin_document.dart';
import '../../domain/usecases/unpin_document.dart';
import '../../domain/usecases/import_files.dart';
import '../../domain/usecases/remove_file.dart';
import '../../../../services/file_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../search/domain/services/batch_indexing_service.dart';
import '../../../ai/knowledge_graph/domain/services/knowledge_graph_builder.dart';

part 'workspace_detail_viewmodel.g.dart';

enum DocumentSortOption { name, date, size }

class WorkspaceDetailState {
  
  const WorkspaceDetailState({
    this.workspace,
    this.allFiles = const [],
    this.pinnedFiles = const [],
    this.sortOption = DocumentSortOption.date,
  });
  final Workspace? workspace;
  final List<WorkspaceFile> allFiles;
  final List<WorkspaceFile> pinnedFiles;
  final DocumentSortOption sortOption;

  WorkspaceDetailState copyWith({
    Workspace? workspace,
    List<WorkspaceFile>? allFiles,
    List<WorkspaceFile>? pinnedFiles,
    DocumentSortOption? sortOption,
  }) => WorkspaceDetailState(
      workspace: workspace ?? this.workspace,
      allFiles: allFiles ?? this.allFiles,
      pinnedFiles: pinnedFiles ?? this.pinnedFiles,
      sortOption: sortOption ?? this.sortOption,
    );
}

@riverpod
class WorkspaceDetailViewModel extends _$WorkspaceDetailViewModel {
  late final GetWorkspaceFiles _getWorkspaceFiles;
  late final PinDocument _pinDocument;
  late final UnpinDocument _unpinDocument;
  late final ImportFile _importFile;
  late final RemoveFile _removeFile;
  late final FileService _fileService;

  @override
  FutureOr<WorkspaceDetailState> build(String workspaceId) async {
    final repo = ref.watch(workspaceRepositoryProvider);
    _getWorkspaceFiles = GetWorkspaceFiles(repo);
    _pinDocument = PinDocument(repo);
    _unpinDocument = UnpinDocument(repo);
    _importFile = ImportFile(repo);
    _removeFile = RemoveFile(repo);
    _fileService = ref.watch(fileServiceProvider);

    return _fetchData(workspaceId);
  }

  Future<WorkspaceDetailState> _fetchData(String workspaceId) async {
    final repo = ref.read(workspaceRepositoryProvider);
    
    // Fetch workspace
    final workspaceResult = await repo.getWorkspaceById(workspaceId);
    final workspace = workspaceResult.fold(
      (failure) => null,
      (w) => w,
    );

    // Fetch files
    final filesResult = await _getWorkspaceFiles(workspaceId);
    final files = filesResult.fold(
      (failure) => <WorkspaceFile>[],
      (f) => f,
    );

    // Fetch pinned files
    final pinnedResult = await repo.getPinnedDocuments(workspaceId);
    final pinnedFiles = pinnedResult.fold(
      (failure) => <WorkspaceFile>[],
      (f) => f,
    );

    return WorkspaceDetailState(
      workspace: workspace,
      allFiles: _sortFiles(files, DocumentSortOption.date),
      pinnedFiles: pinnedFiles,
    );
  }
  
  List<WorkspaceFile> _sortFiles(List<WorkspaceFile> files, DocumentSortOption option) {
    final sorted = List<WorkspaceFile>.from(files);
    switch (option) {
      case DocumentSortOption.name:
        sorted.sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
      case DocumentSortOption.date:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DocumentSortOption.size:
        sorted.sort((a, b) => (b.size ?? 0).compareTo(a.size ?? 0));
        break;
    }
    return sorted;
  }

  void setSortOption(DocumentSortOption option) {
    if (state.hasValue && state.value != null) {
      final current = state.value!;
      state = AsyncValue.data(current.copyWith(
        sortOption: option,
        allFiles: _sortFiles(current.allFiles, option),
      ));
    }
  }

  Future<void> pinFile(String fileId) async {
    if (!state.hasValue || state.value == null) return;
    final result = await _pinDocument(fileId, workspaceId);
    if (result.isRight()) {
      // Reload the state to refresh pinned documents correctly
      state = AsyncValue.data(await _fetchData(workspaceId));
    }
  }

  Future<void> unpinFile(String fileId) async {
    if (!state.hasValue || state.value == null) return;
    final result = await _unpinDocument(fileId, workspaceId);
    if (result.isRight()) {
      state = AsyncValue.data(await _fetchData(workspaceId));
    }
  }

  Future<void> removeFile(String fileId) async {
    if (!state.hasValue || state.value == null) return;
    final result = await _removeFile(fileId);
    await result.fold(
      (failure) async => throw Exception(failure.message),
      (_) async {
        // Re-fetch so the workspace stays open with the file gone; do not pop.
        state = AsyncValue.data(await _fetchData(workspaceId));
      },
    );
  }

  Future<void> importFiles() async {
    if (!state.hasValue || state.value == null) return;
    
    // Instead of custom loading flag, use native AsyncValue loading
    state = const AsyncValue.loading();
    
    try {
      final pickedFiles = await _fileService.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg', 'webp'],
      );
      
      if (pickedFiles.isEmpty) {
        state = AsyncValue.data(await _fetchData(workspaceId));
        return;
      }

      final imported = <WorkspaceFile>[];
      for (final picked in pickedFiles) {
        final meta = await _fileService.importFileToAppStorage(picked);
        final result = await _importFile(workspaceId, meta);
        result.fold((_) {}, imported.add);
      }

      // Build the search index for what was just imported. Without this a
      // document is invisible to search: KeywordSearchEngine skips every
      // candidate that has no persisted SearchIndex, so an unindexed
      // document can never match a query. Indexing runs in the background,
      // and KeywordSearchEngine indexes on demand if a query arrives first.
      if (imported.isNotEmpty) {
        await sl<BatchIndexingService>().enqueueBatch(imported);

        // Extend the knowledge graph with what was just imported. The graph is
        // also built lazily the first time an empty one is opened, which covers
        // documents imported before this ran; this keeps an already-populated
        // graph current without waiting for that screen.
        //
        // A graph failure must not fail the import: the files are on disk and
        // in the database by this point, and the graph is a derived view.
        try {
          await sl<KnowledgeGraphBuilder>().buildGraph(
            workspaceId: workspaceId,
            modifiedDocumentIds: imported.map((f) => f.id).toList(),
          );
        } catch (_) {
          // Left for the graph screen's own rebuild to retry.
        }
      }

      state = AsyncValue.data(await _fetchData(workspaceId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
