import '../entities/search_query.dart';
import '../entities/search_result.dart';

abstract class AbstractHybridSearchOrchestrator {
  Future<List<SearchResult>> search(SearchQuery query);
}
