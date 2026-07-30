import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/riverpod_providers.dart';
import '../../../../core/utils/app_logger.dart';

import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../../core/utils/file_type_helper.dart';
import '../../domain/entities/viewer_type.dart';
import '../../domain/entities/document_view_state.dart';
import '../../../../../core/text_engine/models/text_document.dart';
import '../../domain/entities/reading_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/reading_preferences_local_datasource.dart';

part 'document_viewer_viewmodel.g.dart';

class DocumentViewerViewModelState {

  const DocumentViewerViewModelState({
    this.file,
    this.viewerType = ViewerType.unsupported,
    this.viewState = const DocumentViewState(),
    this.textDocument,
    this.readingPreferences = const ReadingPreferences(),
  });
  final WorkspaceFile? file;
  final ViewerType viewerType;
  final DocumentViewState viewState;
  final TextDocument? textDocument;
  final ReadingPreferences readingPreferences;

  DocumentViewerViewModelState copyWith({
    WorkspaceFile? file,
    ViewerType? viewerType,
    DocumentViewState? viewState,
    TextDocument? textDocument,
    ReadingPreferences? readingPreferences,
  }) => DocumentViewerViewModelState(
      file: file ?? this.file,
      viewerType: viewerType ?? this.viewerType,
      viewState: viewState ?? this.viewState,
      textDocument: textDocument ?? this.textDocument,
      readingPreferences: readingPreferences ?? this.readingPreferences,
    );
}

@riverpod
class DocumentViewerViewModel extends _$DocumentViewerViewModel {
  DocumentViewerViewModelState? get currentState => state.valueOrNull;

  @override
  FutureOr<DocumentViewerViewModelState> build(String documentId) async => _fetchDocument(documentId);

  Future<DocumentViewerViewModelState> _fetchDocument(String documentId) async {
    AppLogger.info('DocumentViewerViewModel: Loading document $documentId');
    final useCase = ref.read(getDocumentForViewingProvider);
    
    final result = await useCase(documentId);
    
    final resultState = result.fold(
      (failure) {
        AppLogger.error('DocumentViewerViewModel: Failed to load document $documentId', failure.message);
        throw Exception(failure.message);
      },
      (file) {
        final viewerType = FileTypeHelper.getViewerType(file.extension);
        AppLogger.info('DocumentViewerViewModel: Document loaded successfully. Type: $viewerType');
        
        // Trigger metadata update for recent documents.
        // addRecentDocument already updates last_opened_at and open_count in a
        // single SQL statement, so no separate calls are needed.
        ref.read(recentDocumentsServiceProvider).addRecentDocument(file.id);
        AppLogger.info('DocumentViewerViewModel: Document opened event logged for ${file.id}');
        
        // Restore initial view state from file metadata
        final initialViewState = DocumentViewState(
          currentPage: file.lastViewedPage ?? 1,
          zoomLevel: file.lastZoomLevel ?? 1.0,
          scrollPosition: file.lastScrollPosition ?? 0.0,
          lastOpenedAt: file.lastOpenedAt,
        );
        
        return DocumentViewerViewModelState(
          file: file,
          viewerType: viewerType,
          viewState: initialViewState,
        );
      },
    );
    
    // If it's a text document, load text parsing and reading preferences.
    if (resultState.viewerType == ViewerType.text || resultState.viewerType == ViewerType.docx) {
      return await _loadTextDocumentAdditions(resultState);
    }
    
    return resultState;
  }

  Future<DocumentViewerViewModelState> _loadTextDocumentAdditions(DocumentViewerViewModelState currentState) async {
    try {
      const storage = FlutterSecureStorage();
      final prefsDataSource = ReadingPreferencesLocalDataSource(storage);
      final prefs = await prefsDataSource.getPreferences();
      
      final textEngine = ref.read(textEngineProvider);
      final textDoc = await textEngine.openDocument(currentState.file!);
      
      return currentState.copyWith(
        textDocument: textDoc,
        readingPreferences: prefs,
      );
    } catch (e) {
      AppLogger.error('DocumentViewerViewModel: Text parse failed', e.toString());
      throw Exception('Failed to parse document: $e');
    }
  }

  void updatePageState(int page, int totalPages) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    
    AppLogger.info('DocumentViewerViewModel: Page changed to $page/$totalPages');
    state = AsyncValue.data(currentState.copyWith(
      viewState: currentState.viewState.copyWith(
        currentPage: page,
        pageCount: totalPages,
      )
    ));
    saveViewerState();
  }

  void jumpToPage(int page) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    if (page < 1 || page > currentState.viewState.pageCount) return;
    
    state = AsyncValue.data(currentState.copyWith(
      viewState: currentState.viewState.copyWith(currentPage: page)
    ));
    saveViewerState();
  }

  void nextPage() {
    if (!state.hasValue) return;
    final current = state.value!.viewState.currentPage;
    jumpToPage(current + 1);
  }

  void previousPage() {
    if (!state.hasValue) return;
    final current = state.value!.viewState.currentPage;
    jumpToPage(current - 1);
  }

  void zoomIn() {
    if (!state.hasValue) return;
    final current = state.value!.viewState.zoomLevel;
    updateZoom(current + 0.25);
  }

  void zoomOut() {
    if (!state.hasValue) return;
    final current = state.value!.viewState.zoomLevel;
    updateZoom(current - 0.25);
  }

  void resetZoom() {
    updateZoom(1.0);
  }

  void updateZoom(double zoom) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    // Clamp zoom to reasonable levels
    final clampedZoom = zoom.clamp(0.5, 5.0); // Allow higher zoom for images
    
    AppLogger.info('DocumentViewerViewModel: Zoom changed to $clampedZoom');
    state = AsyncValue.data(currentState.copyWith(
      viewState: currentState.viewState.copyWith(zoomLevel: clampedZoom)
    ));
    
    saveViewerState();
  }
  
  void rotateLeft() {
    if (!state.hasValue) return;
    final currentRotation = state.value!.viewState.rotation;
    _updateRotation(currentRotation - 90.0); // Standard 90-degree steps for images
  }

  void rotateRight() {
    if (!state.hasValue) return;
    final currentRotation = state.value!.viewState.rotation;
    _updateRotation(currentRotation + 90.0);
  }

  void _updateRotation(double rotation) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    
    // Keep rotation bounded between 0 and 360 (or -180 and 180)
    final normalized = rotation % 360.0;
    
    AppLogger.info('DocumentViewerViewModel: Rotation changed to $normalized');
    state = AsyncValue.data(currentState.copyWith(
      viewState: currentState.viewState.copyWith(rotation: normalized)
    ));
    
    // Rotation is typically not persisted per requirements, but we update state.
  }

  void setPasswordProtected(bool isProtected) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    if (isProtected) {
      AppLogger.warning('DocumentViewerViewModel: Password protected document encountered');
    }
    state = AsyncValue.data(currentState.copyWith(
      viewState: currentState.viewState.copyWith(isPasswordProtected: isProtected)
    ));
  }

  void updateScrollPosition(double position) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    
    state = AsyncValue.data(currentState.copyWith(
      viewState: currentState.viewState.copyWith(scrollPosition: position)
    ));
    
    // We don't save immediately here to avoid thrashing the DB on scroll.
    // Relies on saveViewerState() on dispose.
  }

  Future<void> updateReadingPreferences(ReadingPreferences prefs) async {
    if (!state.hasValue) return;
    final currentState = state.value!;
    
    state = AsyncValue.data(currentState.copyWith(readingPreferences: prefs));
    
    const storage = FlutterSecureStorage();
    final prefsDataSource = ReadingPreferencesLocalDataSource(storage);
    await prefsDataSource.savePreferences(prefs);
  }

  Future<void> saveViewerState() async {
    if (!state.hasValue || state.value?.file == null) return;
    
    final viewState = state.value!.viewState;
    final fileId = state.value!.file!.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final repo = ref.read(documentViewerRepositoryProvider);
    await repo.updateViewerState(
      fileId,
      lastOpenedAt: timestamp,
      lastViewedPage: viewState.currentPage,
      lastZoomLevel: viewState.zoomLevel,
      lastScrollPosition: viewState.scrollPosition,
    );
    
    AppLogger.info('DocumentViewerViewModel: Saved viewer state for $fileId');
  }

  void restoreViewerState() {
    // Already handled in _fetchDocument during initialization.
  }

  void search(String keyword) {
    throw UnimplementedError('Search functionality is planned for Phase 5');
  }
}
