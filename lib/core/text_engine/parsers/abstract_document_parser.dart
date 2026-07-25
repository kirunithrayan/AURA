import '../models/text_document.dart';
import '../../../features/workspace/domain/entities/workspace_file.dart';

abstract class AbstractDocumentParser {
  Future<TextDocument> parse(WorkspaceFile file);
  bool supportsExtension(String extension);
  Future<Map<String, dynamic>> extractMetadata(WorkspaceFile file);
}
