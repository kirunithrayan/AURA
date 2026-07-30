import 'dart:io';
import 'package:crypto/crypto.dart';

/// Utility class for file operations.
class FileUtils {
  FileUtils._();

  /// Extracts the file extension from a file path.
  static String getExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return '';
    return path.substring(dotIndex + 1).toLowerCase();
  }

  /// Extracts the file name (with extension) from a file path.
  static String getFileName(String path) {
    final slashIndex = path.lastIndexOf(Platform.pathSeparator);
    if (slashIndex == -1) return path;
    return path.substring(slashIndex + 1);
  }

  /// Extracts the file name without extension from a file path.
  static String getFileNameWithoutExtension(String path) {
    final name = getFileName(path);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return name;
    return name.substring(0, dotIndex);
  }

  /// Calculates the SHA-256 hash of a file for duplicate detection.
  static Future<String> calculateFileHash(File file) async {
    final stream = file.openRead();
    final hash = await sha256.bind(stream).first;
    return hash.toString();
  }

  /// Generates a safe file name by removing invalid characters.
  static String sanitizeFileName(String name) => name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

  /// Returns the MIME type based on file extension.
  static String getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
