import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import 'viewer_lifecycle.dart';
import 'image/abstract_image_controller.dart';
import 'image/image_engine_wrapper.dart';

class ImageViewerWidget extends ConsumerStatefulWidget {

  const ImageViewerWidget({super.key, required this.file});
  final WorkspaceFile file;

  @override
  ConsumerState<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends ConsumerState<ImageViewerWidget> implements ViewerLifecycle {
  late final AbstractImageController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = ImageEngineControllerImpl();
    onViewerOpened();
  }

  @override
  void dispose() {
    onViewerClosed();
    _imageController.close();
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
    final stateAsync = ref.watch(documentViewerViewModelProvider(widget.file.id));

    return stateAsync.when(
      data: (state) => Container(
          color: Colors.black, // Dark background for images
          child: Center(
            child: ImageEngineWrapper(
              filePath: widget.file.filePath,
              initialZoom: state.viewState.zoomLevel,
              initialRotation: state.viewState.rotation,
              controller: _imageController,
              onZoomChanged: (zoom) {
                ref.read(documentViewerViewModelProvider(widget.file.id).notifier).updateZoom(zoom);
              },
              onTap: () {},
            ),
          ),
        ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => AuraEmptyState(icon: Icons.error, title: 'Error', message: e.toString()),
    );
  }
}
