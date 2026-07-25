import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'abstract_image_controller.dart';

class ImageEngineWrapper extends StatefulWidget {
  final String filePath;
  final double initialZoom;
  final double initialRotation; // In degrees
  final AbstractImageController controller;
  final void Function(double zoom) onZoomChanged;
  final VoidCallback onTap;

  const ImageEngineWrapper({
    super.key,
    required this.filePath,
    required this.initialZoom,
    required this.initialRotation,
    required this.controller,
    required this.onZoomChanged,
    required this.onTap,
  });

  @override
  State<ImageEngineWrapper> createState() => _ImageEngineWrapperState();
}

class _ImageEngineWrapperState extends State<ImageEngineWrapper> {
  late PhotoViewController _photoViewController;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController(
      initialScale: widget.initialZoom,
    );
    
    // Convert degrees to radians for PhotoView
    _photoViewController.rotation = widget.initialRotation * (pi / 180.0);
    
    if (widget.controller is ImageEngineControllerImpl) {
      (widget.controller as ImageEngineControllerImpl).attach(_photoViewController);
    }
    
    _photoViewController.outputStateStream.listen((event) {
      if (event.scale != null) {
        widget.onZoomChanged(event.scale!);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ImageEngineWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRotation != widget.initialRotation) {
      _photoViewController.rotation = widget.initialRotation * (pi / 180.0);
    }
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: PhotoView(
        imageProvider: FileImage(File(widget.filePath)),
        controller: _photoViewController,
        minScale: PhotoViewComputedScale.contained * 0.5,
        maxScale: PhotoViewComputedScale.covered * 5.0,
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent, // Adaptive background will be handled by the parent
        ),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
        ),
      ),
    );
  }
}

class ImageEngineControllerImpl implements AbstractImageController {
  PhotoViewController? _controller;

  void attach(PhotoViewController controller) {
    _controller = controller;
  }

  @override
  Future<void> openImage(String path) async {}

  @override
  void zoomIn() {
    if (_controller != null) {
      final currentScale = _controller!.scale ?? 1.0;
      _controller!.scale = currentScale + 0.25;
    }
  }

  @override
  void zoomOut() {
    if (_controller != null) {
      final currentScale = _controller!.scale ?? 1.0;
      _controller!.scale = (currentScale - 0.25).clamp(0.5, 5.0);
    }
  }

  @override
  void resetZoom() {
    if (_controller != null) {
      _controller!.scale = 1.0; // Wait for initialScale or just 1.0
    }
  }

  @override
  void rotateLeft() {
    // Rotation is driven completely by the ViewModel rebuilding the widget.
  }

  @override
  void rotateRight() {
    // Rotation is driven completely by the ViewModel rebuilding the widget.
  }

  @override
  double getZoomLevel() {
    return _controller?.scale ?? 1.0;
  }

  @override
  void close() {
    _controller = null;
  }
}
