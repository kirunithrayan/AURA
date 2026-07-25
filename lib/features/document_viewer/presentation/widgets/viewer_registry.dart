import 'package:flutter/material.dart';
import '../../domain/entities/viewer_type.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import 'viewers/pdf_viewer_widget.dart';
import 'viewers/image_viewer_widget.dart';
import 'viewers/text_viewer_widget.dart';
import 'viewers/unsupported_viewer_placeholder.dart';

class ViewerRegistry {
  ViewerRegistry._();

  static Widget getViewer(ViewerType type, WorkspaceFile file) {
    switch (type) {
      case ViewerType.pdf:
        return PdfViewerWidget(file: file);
      case ViewerType.image:
        return ImageViewerWidget(file: file);
      case ViewerType.text:
      case ViewerType.docx:
        return TextViewerWidget(file: file);
      case ViewerType.unsupported:
      default:
        return UnsupportedViewerPlaceholder(file: file);
    }
  }
}
