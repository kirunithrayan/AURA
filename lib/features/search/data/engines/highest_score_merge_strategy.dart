import '../../domain/engines/abstract_merge_strategy.dart';
import '../../domain/entities/search_result.dart';

class HighestScoreMergeStrategy implements AbstractMergeStrategy {
  @override
  List<SearchResult> merge(List<List<SearchResult>> engineResults) {
    // Flatten the list from all engines. Duplicate resolution and
    // keeping the highest score logic is applied in the DuplicateResolver.
    return engineResults.expand((results) => results).toList();
  }
}
