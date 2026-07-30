import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

import '../core/error/exceptions.dart';
import '../core/utils/file_utils.dart';

class FileMetadata {

  FileMetadata({
    required this.fileName,
    required this.filePath,
    required this.originalPath,
    required this.extension,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
    required this.contentHash,
  });
  final String fileName;
  final String filePath;
  final String originalPath;
  final String extension;
  final String mimeType;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String contentHash;
}

/// Service for handling file system operations (importing, copying, metadata extraction).
class FileService {
  final Uuid _uuid = const Uuid();

  /// Opens the system file picker and returns a list of picked files.
  Future<List<PlatformFile>> pickFiles({
    bool allowMultiple = true,
    List<String>? allowedExtensions = const ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      return result?.files ?? [];
    } catch (e) {
      throw FileSystemException('Failed to open file picker: $e');
    }
  }

  /// Copies a picked file into the app's internal storage directory and extracts metadata.
  Future<FileMetadata> importFileToAppStorage(PlatformFile pickedFile) async {
    if (pickedFile.path == null) {
      throw const FileSystemException('Picked file has no valid path');
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final auraDir = Directory(p.join(appDir.path, 'AURA_Documents'));
      
      if (!await auraDir.exists()) {
        await auraDir.create(recursive: true);
      }

      final sourceFile = File(pickedFile.path!);
      final extension = FileUtils.getExtension(pickedFile.name);
      final uniqueFileName = '${_uuid.v4()}${extension.isNotEmpty ? '.$extension' : ''}';
      final destinationPath = p.join(auraDir.path, uniqueFileName);

      // Copy file to internal storage
      final copiedFile = await sourceFile.copy(destinationPath);
      
      // Extract metadata
      final stat = await copiedFile.stat();
      final contentHash = await _calculateSha256(copiedFile);

      return FileMetadata(
        fileName: pickedFile.name,
        filePath: destinationPath,
        originalPath: pickedFile.path!,
        extension: extension,
        mimeType: FileUtils.getMimeType(extension),
        size: stat.size,
        createdAt: stat.changed, // File creation time in internal storage
        modifiedAt: stat.modified,
        contentHash: contentHash,
      );
    } catch (e) {
      throw FileSystemException('Failed to import file: $e');
    }
  }

  Future<String> _calculateSha256(File file) async {
    final stream = file.openRead();
    final hash = await sha256.bind(stream).first;
    return hash.toString();
  }

  /// Deletes a file from the app's internal storage.
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSystemException('Failed to delete file: $e');
    }
  }
}
