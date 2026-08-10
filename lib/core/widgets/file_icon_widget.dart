import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../extensions/context_extensions.dart';

/// A widget that displays the appropriate icon for a given file extension.
///
/// Design System: file glyphs are monochrome (`content.tertiary`). Colored
/// file-type badges are prohibited — only the glyph shape distinguishes type.
class FileIconWidget extends StatelessWidget {

  const FileIconWidget({
    super.key,
    required this.extension,
    this.size = UiConstants.fileIconSize,
    this.color,
  });
  final String extension;
  final double size;
  final Color? color;

  IconData _iconFor(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
      case 'md':
        return Icons.article;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return Icons.image;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) => Icon(
        _iconFor(extension.toLowerCase().replaceAll('.', '')),
        size: size,
        color: color ?? context.tokens.colors.contentTertiary,
      );
}
