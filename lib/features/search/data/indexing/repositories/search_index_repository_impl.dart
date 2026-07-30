import '../../../domain/entities/indexing/search_index.dart';
import '../datasources/search_index_local_datasource.dart';
import 'search_index_repository.dart';

/// Concrete implementation delegating all storage to the local datasource.
class SearchIndexRepositoryImpl implements SearchIndexRepository {

  SearchIndexRepositoryImpl(this._localDatasource);
  final SearchIndexLocalDatasource _localDatasource;

  @override
  Future<void> saveIndex(SearchIndex index) => _localDatasource.saveIndex(index);

  @override
  Future<SearchIndex?> getIndex(String documentId) => _localDatasource.getIndex(documentId);

  @override
  Future<void> deleteIndex(String documentId) => _localDatasource.deleteIndex(documentId);

  @override
  Future<({String? checksum, String? parserVersion})?> getIndexMeta(String documentId) =>
      _localDatasource.getIndexMeta(documentId);

  @override
  Future<List<String>> getIndexedDocumentIds(String workspaceId) =>
      _localDatasource.getIndexedDocumentIds(workspaceId);
}
