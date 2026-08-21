import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import '../base_viewer_screen.dart';
import 'viewer_lifecycle.dart';
import 'pdf/abstract_pdf_controller.dart';
import 'pdf/pdf_engine_wrapper.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {

  const PdfViewerWidget({super.key, required this.file});
  final WorkspaceFile file;

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> implements ViewerLifecycle {
  late final AbstractPdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfEngineControllerImpl();
    onViewerOpened();
  }

  @override
  void dispose() {
    onViewerClosed();
    _pdfController.close();
    super.dispose();
  }

  @override
  void onViewerOpened() {}

  @override
  void onViewerPaused() {}

  @override
  void onViewerResumed() {}

  @override
  void onViewerClosed() {
    ref.read(documentViewerViewModelProvider(widget.file.id).notifier).saveViewerState();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes to drive the controller
    ref.listen(documentViewerViewModelProvider(widget.file.id), (previous, next) {
      if (previous?.value?.viewState.currentPage != next.value?.viewState.currentPage) {
        if (next.value != null) _pdfController.jumpToPage(next.value!.viewState.currentPage);
      }
    });

    final stateAsync = ref.watch(documentViewerViewModelProvider(widget.file.id));

    return stateAsync.when(
      data: (state) {
        final Widget content = state.viewState.isPasswordProtected
            ? const AuraEmptyState(
                icon: Icons.lock,
                title: 'Password Protected',
                message: 'This PDF requires a password to open, which is currently unsupported.',
              )
            : PdfEngineWrapper(
                filePath: widget.file.filePath,
                initialPage: state.viewState.currentPage,
                initialZoom: state.viewState.zoomLevel,
                controller: _pdfController,
                onPageChanged: (page, total) {
                  ref.read(documentViewerViewModelProvider(widget.file.id).notifier).updatePageState(page, total);
                },
                onZoomChanged: (zoom) {
                  ref.read(documentViewerViewModelProvider(widget.file.id).notifier).updateZoom(zoom);
                },
                onPasswordProtected: (protected) {
                  ref.read(documentViewerViewModelProvider(widget.file.id).notifier).setPasswordProtected(protected);
                },
              );

        return BaseViewerScreen(
          title: widget.file.fileName,
          file: widget.file,
          child: content,
        );
      },
      loading: () => const BaseViewerScreen(title: 'Loading', isLoading: true, child: SizedBox.shrink()),
      error: (e, st) => BaseViewerScreen(title: 'Error', error: e.toString(), child: const SizedBox.shrink()),
    );
  }
}
