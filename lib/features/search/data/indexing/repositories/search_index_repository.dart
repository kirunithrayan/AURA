import '../../../domain/entities/indexing/search_index.dart';

/// Contract for search index storage operations.
/// Hides all SQL details behind a clean domain interface.
abstract class SearchIndexRepository {
  Future<void> saveIndex(SearchIndex index);
  Future<SearchIndex?> getIndex(String documentId);
  Future<void> deleteIndex(String documentId);
  Future<({String? checksum, String? parserVersion})?> getIndexMeta(String documentId);
  Future<List<String>> getIndexedDocumentIds(String workspaceId);
}
