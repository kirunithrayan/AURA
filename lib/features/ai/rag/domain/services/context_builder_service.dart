import '../../../../search/domain/entities/search_result.dart';
import '../entities/context_chunk.dart';

abstract class ContextBuilderService {
  /// Builds a prioritized list of context chunks from search results.
  /// Includes deduplication, neighboring chunk inclusion, and truncation 
  /// based on max token limit approximation.
  Future<List<ContextChunk>> buildContext(List<SearchResult> results, {int maxLength = 3000});
}
