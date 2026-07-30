import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/search_query.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';
import '../datasources/local_search_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {

  SearchRepositoryImpl(this._localDatasource);
  final LocalSearchDatasource _localDatasource;

  @override
  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async => _localDatasource.getCandidateMetadata(query);
}
