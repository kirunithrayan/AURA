import 'abstract_document_parser.dart';
import 'txt_parser.dart';
import 'docx_parser.dart';
import 'pdf_parser.dart';
import 'image_parser.dart';

class ParserRegistry {
  ParserRegistry._();

  static final List<AbstractDocumentParser> _parsers = [
    TxtParser(),
    DocxParser(),
    PdfParser(),
    ImageParser(),
  ];

  static AbstractDocumentParser? getParserForExtension(String extension) {
    for (final parser in _parsers) {
      if (parser.supportsExtension(extension)) {
        return parser;
      }
    }
    return null;
  }
}
