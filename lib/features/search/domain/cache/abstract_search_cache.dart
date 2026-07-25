import '../entities/search_result.dart';
import '../entities/optimization/search_cache_key.dart';
import '../entities/optimization/search_cache_statistics.dart';

abstract class AbstractSearchCache {
  void put(SearchCacheKey key, List<SearchResult> results);
  List<SearchResult>? get(SearchCacheKey key);
  void invalidate();
  SearchCacheStatistics getStatistics();
}
