import 'models/text_document.dart';
import '../../features/document_viewer/domain/entities/viewer_search_result.dart';
import '../../features/workspace/domain/entities/workspace_file.dart';

abstract class AbstractTextDocumentEngine {
  Future<TextDocument> openDocument(WorkspaceFile file);
  void close();
  TextDocument? getDocument();
  Map<String, dynamic> getMetadata();
  double getScrollPosition();
  void setScrollPosition(double position);
  ViewerSearchResult search(String keyword);
}
