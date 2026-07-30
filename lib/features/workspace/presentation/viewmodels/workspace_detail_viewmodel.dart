import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/riverpod_providers.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_file.dart';
import '../../domain/usecases/get_workspace_files.dart';
import '../../domain/usecases/pin_document.dart';
import '../../domain/usecases/unpin_document.dart';
import '../../domain/usecases/import_files.dart';
import '../../../../services/file_service.dart';

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
  late final FileService _fileService;

  @override
  FutureOr<WorkspaceDetailState> build(String workspaceId) async {
    final repo = ref.watch(workspaceRepositoryProvider);
    _getWorkspaceFiles = GetWorkspaceFiles(repo);
    _pinDocument = PinDocument(repo);
    _unpinDocument = UnpinDocument(repo);
    _importFile = ImportFile(repo);
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

  Future<void> importFiles() async {
    if (!state.hasValue || state.value == null) return;
    
    // Instead of custom loading flag, use native AsyncValue loading
    state = const AsyncValue.loading();
    
    try {
      final pickedFiles = await _fileService.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
      );
      
      if (pickedFiles.isEmpty) {
        state = AsyncValue.data(await _fetchData(workspaceId));
        return;
      }

      for (final picked in pickedFiles) {
        final meta = await _fileService.importFileToAppStorage(picked);
        await _importFile(workspaceId, meta);
      }
      
      state = AsyncValue.data(await _fetchData(workspaceId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
