import '../entities/search_execution_context.dart';
import '../entities/search_result.dart';

abstract class AbstractSearchPostProcessor {
  Future<List<SearchResult>> process(
      SearchExecutionContext context, List<SearchResult> rankedResults);
}
