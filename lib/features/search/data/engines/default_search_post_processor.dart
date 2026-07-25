import '../../domain/engines/abstract_search_post_processor.dart';
import '../../domain/entities/search_execution_context.dart';
import '../../domain/entities/search_result.dart';

class DefaultSearchPostProcessor implements AbstractSearchPostProcessor {
  @override
  Future<List<SearchResult>> process(
      SearchExecutionContext context, List<SearchResult> rankedResults) async {
    // Basic pass-through post processor
    return rankedResults;
  }
}
