import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/search_query.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';
import '../datasources/local_search_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final LocalSearchDatasource _localDatasource;

  SearchRepositoryImpl(this._localDatasource);

  @override
  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async {
    return _localDatasource.getCandidateMetadata(query);
  }
}
