import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../extensions/context_extensions.dart';

/// A widget that displays the appropriate icon for a given file extension.
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

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    final ext = extension.toLowerCase().replaceAll('.', '');

    switch (ext) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'txt':
      case 'md':
        iconData = Icons.article;
        iconColor = Colors.grey;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case 'xls':
      case 'xlsx':
      case 'csv':
        iconData = Icons.table_chart;
        iconColor = Colors.green[700]!;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = context.theme.colorScheme.outline;
    }

    return Icon(
      iconData,
      size: size,
      color: color ?? iconColor,
    );
  }
}
