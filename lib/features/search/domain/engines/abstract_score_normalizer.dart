import '../entities/search_result.dart';

abstract class AbstractScoreNormalizer {
  List<SearchResult> normalize(List<SearchResult> results);
}
