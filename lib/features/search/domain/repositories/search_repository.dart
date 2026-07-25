import '../entities/search_query.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';

abstract class SearchRepository {
  /// Retrieves raw document metadata candidates based on basic query parameters (like workspaceId).
  /// This serves as the single gateway to the database for search engines.
  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query);
}
