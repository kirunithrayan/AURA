import 'dart:io';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../../../features/workspace/domain/entities/workspace_file.dart';
import '../models/text_document.dart';
import 'abstract_document_parser.dart';

class DocxParser implements AbstractDocumentParser {
  @override
  bool supportsExtension(String extension) => extension.toLowerCase() == 'docx';

  @override
  Future<Map<String, dynamic>> extractMetadata(WorkspaceFile file) async => {'parserVersion': '1.0', 'sourceType': 'DOCX'};

  @override
  Future<TextDocument> parse(WorkspaceFile file) async {
    final bytes = await File(file.filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String content = '';
    final List<String> headings = [];
    int paragraphs = 0;

    final documentEntry = archive.findFile('word/document.xml');
    if (documentEntry != null) {
      final xmlString = String.fromCharCodes(documentEntry.content as List<int>);
      final document = XmlDocument.parse(xmlString);

      final pNodes = document.findAllElements('w:p');
      for (final pNode in pNodes) {
        // Build paragraph text
        final rNodes = pNode.findAllElements('w:t');
        String paragraphText = '';
        for (final rNode in rNodes) {
          paragraphText += rNode.innerText;
        }

        if (paragraphText.trim().isNotEmpty) {
          content += '$paragraphText\n\n';
          paragraphs++;

          // Check if it's a heading
          final pPr = pNode.findElements('w:pPr').firstOrNull;
          if (pPr != null) {
            final pStyle = pPr.findElements('w:pStyle').firstOrNull;
            if (pStyle != null) {
              final val = pStyle.getAttribute('w:val');
              if (val != null && val.toLowerCase().startsWith('heading')) {
                headings.add(paragraphText.trim());
              }
            }
          }
        }
      }
    }

    final words = content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    final characters = content.length;
    final readTime = max(1, (words / 200).ceil());

    return TextDocument(
      title: file.fileName,
      content: content.trimRight(),
      headings: headings,
      paragraphCount: paragraphs,
      wordCount: words,
      characterCount: characters,
      sourceType: 'DOCX',
      encoding: 'UTF-8',
      estimatedReadingTime: readTime,
      parserVersion: '1.0',
    );
  }
}
