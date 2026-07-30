import '../entities/search_query.dart';
import '../entities/search_result.dart';

abstract class AbstractRankingEngine {
  /// Sorts and ranks candidate results based on the search query
  Future<List<SearchResult>> rank(SearchQuery query, List<SearchResult> candidates);
}
