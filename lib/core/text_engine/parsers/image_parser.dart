import '../../../features/workspace/domain/entities/workspace_file.dart';
import '../models/text_document.dart';
import 'abstract_document_parser.dart';

/// Makes image files searchable by filename without performing OCR.
///
/// Images carry no extractable text layer, so this parser returns an
/// empty-content [TextDocument] whose title is the file name. That is enough
/// for the indexing pipeline to build a valid (content-empty) index and for
/// filename/title matching to find the image — mirroring how a scanned,
/// text-layer-free PDF is already handled by [PdfParser]. OCR / image-content
/// search is intentionally out of scope here.
class ImageParser implements AbstractDocumentParser {
  static const Set<String> _supported = {'png', 'jpg', 'jpeg', 'webp'};

  @override
  bool supportsExtension(String extension) =>
      _supported.contains(extension.toLowerCase());

  @override
  Future<Map<String, dynamic>> extractMetadata(WorkspaceFile file) async =>
      {'parserVersion': '1.0', 'sourceType': 'IMAGE'};

  // No bytes are read: there is no text layer to extract, and OCR is not part
  // of this feature. The filename (carried as the title) is what makes the
  // image searchable.
  @override
  Future<TextDocument> parse(WorkspaceFile file) async => TextDocument(
        title: file.fileName,
        content: '',
        headings: const [],
        paragraphCount: 0,
        wordCount: 0,
        characterCount: 0,
        sourceType: 'IMAGE',
        encoding: 'UTF-8',
        estimatedReadingTime: 0,
        parserVersion: '1.0',
      );
}
