import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

/// Thrown when a document's format has no printable content path.
class UnsupportedPrintFormatException implements Exception {
  const UnsupportedPrintFormatException(this.extension);
  final String extension;

  @override
  String toString() => 'Printing is not supported for .$extension files.';
}

abstract class DocumentPrintService {
  /// Routes [file] to the native Android/iOS print dialog.
  ///
  /// [textContent] is the already-extracted text for TXT/DOCX (exactly what
  /// the reader currently displays), supplied by the caller so this service
  /// never re-parses the file. PDF and image formats ignore it.
  ///
  /// Throws [UnsupportedPrintFormatException] for a format with no printable
  /// content path, or the underlying I/O exception if the file is missing.
  Future<void> printDocument(WorkspaceFile file, {String? textContent});
}
