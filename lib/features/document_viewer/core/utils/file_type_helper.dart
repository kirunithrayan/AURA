import '../../domain/entities/viewer_type.dart';

class FileTypeHelper {
  FileTypeHelper._();

  static ViewerType getViewerType(String? extension) {
    if (extension == null || extension.isEmpty) return ViewerType.unsupported;

    final ext = extension.toLowerCase();
    switch (ext) {
      case 'pdf':
        return ViewerType.pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return ViewerType.image;
      case 'txt':
        return ViewerType.text;
      case 'docx':
      case 'doc':
        return ViewerType.docx;
      default:
        return ViewerType.unsupported;
    }
  }
}
