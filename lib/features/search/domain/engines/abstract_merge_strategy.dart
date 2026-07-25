import '../entities/search_result.dart';

abstract class AbstractMergeStrategy {
  List<SearchResult> merge(List<List<SearchResult>> engineResults);
}
