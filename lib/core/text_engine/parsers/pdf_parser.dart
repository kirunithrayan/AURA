import 'dart:io';
import 'dart:math';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../features/workspace/domain/entities/workspace_file.dart';
import '../models/text_document.dart';
import 'abstract_document_parser.dart';

/// Extracts embedded text from a text-based PDF using the Syncfusion PDF
/// library that already ships with the app (via `syncfusion_flutter_pdfviewer`).
///
/// Image-only / scanned PDFs carry no text layer, so extraction yields an empty
/// string. That is handled the same as an empty text document — no OCR, no
/// throw — so lazy indexing records an empty index instead of aborting search.
class PdfParser implements AbstractDocumentParser {
  @override
  bool supportsExtension(String extension) => extension.toLowerCase() == 'pdf';

  @override
  Future<Map<String, dynamic>> extractMetadata(WorkspaceFile file) async =>
      {'parserVersion': '1.0', 'sourceType': 'PDF'};

  @override
  Future<TextDocument> parse(WorkspaceFile file) async {
    final bytes = await File(file.filePath).readAsBytes();

    final document = PdfDocument(inputBytes: bytes);
    String rawText;
    try {
      rawText = PdfTextExtractor(document).extractText();
    } finally {
      document.dispose();
    }

    // Syncfusion separates pages with a form-feed (\f); normalise it to a blank
    // line so downstream paragraph/word counting matches the other parsers.
    final content = rawText.replaceAll('\f', '\n\n').trimRight();

    final words =
        content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    final characters = content.length;
    final paragraphs = content.trim().isEmpty
        ? 0
        : content.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty).length;
    final readTime = max(1, (words / 200).ceil());

    return TextDocument(
      title: file.fileName,
      content: content,
      headings: const [], // PDF text has no reliable structural heading markup.
      paragraphCount: paragraphs,
      wordCount: words,
      characterCount: characters,
      sourceType: 'PDF',
      encoding: 'UTF-8',
      estimatedReadingTime: readTime,
      parserVersion: '1.0',
    );
  }
}
