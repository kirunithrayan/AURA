import '../entities/search_result.dart';

abstract class AbstractDuplicateResolver {
  List<SearchResult> resolve(List<SearchResult> mergedResults);
}
