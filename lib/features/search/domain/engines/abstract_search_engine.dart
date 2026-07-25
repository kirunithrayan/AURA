import '../entities/search_query.dart';
import '../entities/search_result.dart';

abstract class AbstractSearchEngine {
  /// The identifier for the engine type (e.g., 'keyword', 'semantic', 'hybrid')
  String get engineType;

  /// Performs a search operation based on the given query.
  Future<List<SearchResult>> search(SearchQuery query);
}
