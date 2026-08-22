// Coverage for the image parser that closes the "Unsupported text format:
// png/jpg/jpeg/webp" gap in search indexing.
//
// Background: workspaces holding an image returned "No results found" — even
// by filename — because ParserRegistry knew only txt/docx/pdf, so
// TextEngineImpl.openDocument threw before any (even empty) index could be
// built, and KeywordSearchEngine skipped the document before filename
// matching ran. ImageParser returns an empty-content TextDocument whose title
// is the file name, so the existing indexing pipeline can index it and the
// existing filename/title matching can find it. OCR is intentionally NOT part
// of this parser — content is empty by design.

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/text_engine/parsers/image_parser.dart';
import 'package:aura/core/text_engine/parsers/pdf_parser.dart';
import 'package:aura/core/text_engine/parsers/txt_parser.dart';
import 'package:aura/core/text_engine/parsers/docx_parser.dart';
import 'package:aura/core/text_engine/parsers/parser_registry.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

WorkspaceFile _imageFile({String fileName = 'photo.png', String extension = 'png'}) =>
    WorkspaceFile(
      id: 'file-$fileName',
      workspaceId: 'ws-1',
      fileName: fileName,
      filePath: '/tmp/$fileName',
      extension: extension,
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

void main() {
  group('ParserRegistry resolves ImageParser', () {
    test('for png, jpg, jpeg, webp', () {
      expect(ParserRegistry.getParserForExtension('png'), isA<ImageParser>());
      expect(ParserRegistry.getParserForExtension('jpg'), isA<ImageParser>());
      expect(ParserRegistry.getParserForExtension('jpeg'), isA<ImageParser>());
      expect(ParserRegistry.getParserForExtension('webp'), isA<ImageParser>());
    });

    test('is case-insensitive for image extensions', () {
      expect(ParserRegistry.getParserForExtension('PNG'), isA<ImageParser>());
      expect(ParserRegistry.getParserForExtension('JPG'), isA<ImageParser>());
      expect(ParserRegistry.getParserForExtension('JPEG'), isA<ImageParser>());
      expect(ParserRegistry.getParserForExtension('WEBP'), isA<ImageParser>());
    });

    test('leaves txt/docx/pdf resolution unchanged', () {
      expect(ParserRegistry.getParserForExtension('txt'), isA<TxtParser>());
      expect(ParserRegistry.getParserForExtension('docx'), isA<DocxParser>());
      expect(ParserRegistry.getParserForExtension('pdf'), isA<PdfParser>());
    });

    test('still returns null for an unsupported extension', () {
      expect(ParserRegistry.getParserForExtension('xlsx'), isNull);
      expect(ParserRegistry.getParserForExtension('gif'), isNull);
    });
  });

  group('ImageParser.supportsExtension', () {
    final parser = ImageParser();
    test('accepts image formats regardless of case', () {
      expect(parser.supportsExtension('png'), isTrue);
      expect(parser.supportsExtension('JPG'), isTrue);
      expect(parser.supportsExtension('jpeg'), isTrue);
      expect(parser.supportsExtension('WebP'), isTrue);
    });
    test('rejects non-image extensions', () {
      expect(parser.supportsExtension('txt'), isFalse);
      expect(parser.supportsExtension('pdf'), isFalse);
      expect(parser.supportsExtension('gif'), isFalse);
    });
  });

  group('ImageParser.parse', () {
    test('preserves the filename as the document title', () async {
      final doc =
          await ImageParser().parse(_imageFile(fileName: 'Lecture Diagram.png'));
      expect(doc.title, 'Lecture Diagram.png');
    });

    test('returns empty content by design (no OCR)', () async {
      final doc = await ImageParser().parse(_imageFile());
      expect(doc.content, isEmpty);
      expect(doc.wordCount, 0);
      expect(doc.characterCount, 0);
      expect(doc.paragraphCount, 0);
      expect(doc.headings, isEmpty);
    });

    test('reports the IMAGE source type and does not throw for any supported '
        'format', () async {
      for (final ext in const ['png', 'jpg', 'jpeg', 'webp']) {
        final doc = await ImageParser().parse(
          _imageFile(fileName: 'pic.$ext', extension: ext),
        );
        expect(doc.sourceType, 'IMAGE');
        expect(doc.title, 'pic.$ext');
      }
    });

    test('does not read the file from disk (works on a non-existent path)',
        () async {
      // filePath points at a file that does not exist; parse must still
      // succeed because no bytes are read.
      final doc = await ImageParser().parse(_imageFile());
      expect(doc.sourceType, 'IMAGE');
    });
  });

  group('ImageParser.extractMetadata', () {
    test('reports the IMAGE source type', () async {
      final meta = await ImageParser().extractMetadata(_imageFile());
      expect(meta['sourceType'], 'IMAGE');
      expect(meta['parserVersion'], '1.0');
    });
  });
}
