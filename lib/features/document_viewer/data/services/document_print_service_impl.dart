import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../../core/utils/file_type_helper.dart';
import '../../domain/entities/viewer_type.dart';
import '../../domain/services/document_print_service.dart';

/// Routes a document to the native print dialog via the `printing` plugin,
/// which wraps Android's PrintManager / iOS's UIPrintInteractionController.
/// No custom printer UI is built here — `Printing.layoutPdf` opens the
/// platform dialog directly.
class DocumentPrintServiceImpl implements DocumentPrintService {
  @override
  Future<void> printDocument(WorkspaceFile file, {String? textContent}) async {
    final source = File(file.filePath);
    if (!await source.exists()) {
      throw const FileSystemException('Cannot print: the document is no longer on disk.');
    }

    final viewerType = FileTypeHelper.getViewerType(file.extension);

    switch (viewerType) {
      case ViewerType.pdf:
        // Direct/native path: the original PDF bytes are handed to the print
        // framework unmodified, so formatting is exactly what the file contains.
        await Printing.layoutPdf(
          name: file.fileName,
          onLayout: (_) => source.readAsBytes(),
        );
        return;

      case ViewerType.image:
        final imageBytes = await source.readAsBytes();
        await Printing.layoutPdf(
          name: file.fileName,
          onLayout: (format) => _imageToPdfBytes(imageBytes, format),
        );
        return;

      case ViewerType.text:
      case ViewerType.docx:
        // The DOCX viewer only ever renders extracted plain text (no tables,
        // styling or images from the original .docx survive parsing), so
        // printing that same text is honest: it matches what the reader
        // actually shows on screen, not a claim of full-fidelity DOCX print.
        final content = textContent;
        if (content == null || content.isEmpty) {
          throw const UnsupportedPrintFormatException('(no extracted text available)');
        }
        await Printing.layoutPdf(
          name: file.fileName,
          onLayout: (format) => _textToPdfBytes(content, format),
        );
        return;

      case ViewerType.unsupported:
        throw UnsupportedPrintFormatException(file.extension ?? '');
    }
  }

  Future<Uint8List> _imageToPdfBytes(Uint8List bytes, PdfPageFormat format) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );
    return doc.save();
  }

  Future<Uint8List> _textToPdfBytes(String content, PdfPageFormat format) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          pw.Text(content, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
    return doc.save();
  }
}
