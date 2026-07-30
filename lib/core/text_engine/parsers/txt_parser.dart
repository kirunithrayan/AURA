import 'dart:io';
import 'dart:math';
import '../../../features/workspace/domain/entities/workspace_file.dart';
import '../models/text_document.dart';
import 'abstract_document_parser.dart';

class TxtParser implements AbstractDocumentParser {
  @override
  bool supportsExtension(String extension) => extension.toLowerCase() == 'txt';

  @override
  Future<Map<String, dynamic>> extractMetadata(WorkspaceFile file) async => {'parserVersion': '1.0', 'sourceType': 'TXT'};

  @override
  Future<TextDocument> parse(WorkspaceFile file) async {
    final localFile = File(file.filePath);
    final content = await localFile.readAsString(); // Assumes UTF-8
    
    final characters = content.length;
    final words = content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    final paragraphs = content.split(RegExp(r'\n\s*\n')).length;
    
    // Very naive reading time estimation (approx 200 words per minute)
    final readTime = max(1, (words / 200).ceil());

    return TextDocument(
      title: file.fileName,
      content: content,
      headings: const [], // TXT files have no standard structural headings
      paragraphCount: paragraphs,
      wordCount: words,
      characterCount: characters,
      sourceType: 'TXT',
      encoding: 'UTF-8',
      estimatedReadingTime: readTime,
      parserVersion: '1.0',
    );
  }
}
