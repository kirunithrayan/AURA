import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'abstract_pdf_controller.dart';

class PdfEngineWrapper extends StatefulWidget {
  final String filePath;
  final int initialPage;
  final double initialZoom;
  final AbstractPdfController controller;
  final void Function(int page, int totalPages) onPageChanged;
  final void Function(double zoom) onZoomChanged;
  final void Function(bool isProtected) onPasswordProtected;

  const PdfEngineWrapper({
    super.key,
    required this.filePath,
    required this.initialPage,
    required this.initialZoom,
    required this.controller,
    required this.onPageChanged,
    required this.onZoomChanged,
    required this.onPasswordProtected,
  });

  @override
  State<PdfEngineWrapper> createState() => _PdfEngineWrapperState();
}

class _PdfEngineWrapperState extends State<PdfEngineWrapper> {
  late PdfViewerController _pdfViewerController;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    
    if (widget.controller is PdfEngineControllerImpl) {
      (widget.controller as PdfEngineControllerImpl).attach(_pdfViewerController);
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(widget.filePath),
      controller: _pdfViewerController,
      initialPageNumber: widget.initialPage,
      initialZoomLevel: widget.initialZoom,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        _pageCount = details.document.pages.count;
        widget.onPageChanged(widget.initialPage, _pageCount);
      },
      onPageChanged: (PdfPageChangedDetails details) {
        widget.onPageChanged(details.newPageNumber, _pageCount);
      },
      onZoomLevelChanged: (PdfZoomDetails details) {
        widget.onZoomChanged(details.newZoomLevel);
      },
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        if (details.error.contains('password') || details.description.contains('password')) {
          widget.onPasswordProtected(true);
        }
      },
    );
  }
}

class PdfEngineControllerImpl implements AbstractPdfController {
  PdfViewerController? _controller;

  void attach(PdfViewerController controller) {
    _controller = controller;
  }

  @override
  Future<void> openDocument(String path) async {}

  @override
  void jumpToPage(int page) {
    _controller?.jumpToPage(page);
  }

  @override
  void nextPage() {
    _controller?.nextPage();
  }

  @override
  void previousPage() {
    _controller?.previousPage();
  }

  @override
  void zoomIn() {
    if (_controller != null) {
      _controller!.zoomLevel = _controller!.zoomLevel + 0.25;
    }
  }

  @override
  void zoomOut() {
    if (_controller != null) {
      _controller!.zoomLevel = (_controller!.zoomLevel - 0.25).clamp(0.5, 3.0);
    }
  }

  @override
  void resetZoom() {
    if (_controller != null) {
      _controller!.zoomLevel = 1.0;
    }
  }

  @override
  int getCurrentPage() {
    return _controller?.pageNumber ?? 1;
  }

  @override
  int getPageCount() {
    return _controller?.pageCount ?? 0;
  }

  @override
  double getZoomLevel() {
    return _controller?.zoomLevel ?? 1.0;
  }

  @override
  void close() {
    _controller = null;
  }
}
