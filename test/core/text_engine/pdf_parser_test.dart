// Coverage for the PDF parser that closes the "Unsupported text format: pdf"
// gap in search indexing.
//
// Background: workspaces holding only a PDF returned "No results found" because
// ParserRegistry knew only txt/docx, so TextEngineImpl.openDocument threw and
// KeywordSearchEngine skipped the document. PdfParser extracts the text layer
// so the existing indexing pipeline can index it.
//
// The fixtures here are REAL PDFs generated at test time with the same
// Syncfusion library the parser reads with — no hand-mocked extraction, no
// hardcoded text fed back through the parser.

import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:aura/core/text_engine/parsers/pdf_parser.dart';
import 'package:aura/core/text_engine/parsers/txt_parser.dart';
import 'package:aura/core/text_engine/parsers/docx_parser.dart';
import 'package:aura/core/text_engine/parsers/parser_registry.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

/// Writes [bytes] to a uniquely named file under the OS temp dir and returns a
/// WorkspaceFile pointing at it.
Future<WorkspaceFile> _fileFrom(List<int> bytes, String name) async {
  final dir = await Directory.systemTemp.createTemp('aura_pdf_test_');
  final path = '${dir.path}/$name';
  await File(path).writeAsBytes(bytes, flush: true);
  return WorkspaceFile(
    id: 'file-$name',
    workspaceId: 'ws-1',
    fileName: name,
    filePath: path,
    extension: 'pdf',
    createdAt: 0,
    modifiedAt: 0,
    importedAt: 0,
  );
}

/// A genuine text-based PDF carrying [lines], one per drawn row.
List<int> _textPdf(List<String> lines) {
  final document = PdfDocument();
  final page = document.pages.add();
  final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
  var y = 0.0;
  for (final line in lines) {
    page.graphics.drawString(
      line,
      font,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(0, y, 500, 20),
    );
    y += 20;
  }
  final bytes = document.saveSync();
  document.dispose();
  return bytes;
}

/// A valid PDF with a blank page and no text layer — models a scanned /
/// image-only document (minus the image, which is irrelevant to extraction).
List<int> _emptyPdf() {
  final document = PdfDocument();
  document.pages.add();
  final bytes = document.saveSync();
  document.dispose();
  return bytes;
}

void main() {
  group('ParserRegistry', () {
    test('resolves PdfParser for the "pdf" extension', () {
      final parser = ParserRegistry.getParserForExtension('pdf');
      expect(parser, isA<PdfParser>());
    });

    test('is case-insensitive for PDF', () {
      expect(ParserRegistry.getParserForExtension('PDF'), isA<PdfParser>());
    });

    test('still resolves txt and docx unchanged', () {
      expect(ParserRegistry.getParserForExtension('txt'), isA<TxtParser>());
      expect(ParserRegistry.getParserForExtension('docx'), isA<DocxParser>());
    });

    test('returns null for an unknown extension', () {
      expect(ParserRegistry.getParserForExtension('xlsx'), isNull);
    });
  });

  group('PdfParser.supportsExtension', () {
    final parser = PdfParser();
    test('accepts pdf regardless of case', () {
      expect(parser.supportsExtension('pdf'), isTrue);
      expect(parser.supportsExtension('PDF'), isTrue);
    });
    test('rejects other extensions', () {
      expect(parser.supportsExtension('txt'), isFalse);
      expect(parser.supportsExtension('docx'), isFalse);
    });
  });

  group('PdfParser.parse', () {
    test('extracts the text layer of a real text-based PDF', () async {
      final file = await _fileFrom(
        _textPdf([
          'Quarterly budget review and infrastructure spending.',
          'Procurement approval is required before headcount planning.',
        ]),
        'notes.pdf',
      );

      final doc = await PdfParser().parse(file);

      expect(doc.content.toLowerCase(), contains('budget'));
      expect(doc.content.toLowerCase(), contains('procurement'));
      expect(doc.content.toLowerCase(), contains('infrastructure'));
      expect(doc.wordCount, greaterThan(0));
      expect(doc.characterCount, doc.content.length);
      expect(doc.sourceType, 'PDF');
      expect(doc.title, 'notes.pdf');
    });

    test('an empty / image-only PDF yields empty text without throwing',
        () async {
      final file = await _fileFrom(_emptyPdf(), 'scanned.pdf');

      final doc = await PdfParser().parse(file);

      expect(doc.content.trim(), isEmpty);
      expect(doc.wordCount, 0);
      expect(doc.paragraphCount, 0);
      expect(doc.sourceType, 'PDF');
    });
  });

  group('PdfParser.extractMetadata', () {
    test('reports the PDF source type', () async {
      final file = await _fileFrom(_textPdf(['hello']), 'meta.pdf');
      final meta = await PdfParser().extractMetadata(file);
      expect(meta['sourceType'], 'PDF');
      expect(meta['parserVersion'], '1.0');
    });
  });
}
