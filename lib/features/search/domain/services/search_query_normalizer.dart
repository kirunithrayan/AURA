import '../entities/search_query.dart';
import '../entities/optimization/normalized_search_query.dart';

abstract class SearchQueryNormalizer {
  /// Normalizes a search query for caching and stable processing.
  NormalizedSearchQuery normalize(SearchQuery query);
}
