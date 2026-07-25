import '../../domain/engines/abstract_duplicate_resolver.dart';
import '../../domain/entities/search_result.dart';

class DefaultDuplicateResolver implements AbstractDuplicateResolver {
  @override
  List<SearchResult> resolve(List<SearchResult> mergedResults) {
    final Map<String, SearchResult> deduplicated = {};

    for (final result in mergedResults) {
      final docId = result.metadata.id;
      if (!deduplicated.containsKey(docId)) {
        deduplicated[docId] = result;
      } else {
        final existing = deduplicated[docId]!;
        
        // Merge logic: Keep the highest score, merge highlights
        final highestScore = result.score > existing.score ? result.score : existing.score;
        final mergedHighlights = {...existing.highlights, ...result.highlights}.toList();
        final bestSnippet = result.score > existing.score ? result.snippet : existing.snippet;
        final bestReason = result.score > existing.score ? result.matchReason : existing.matchReason;
        
        final combinedEngines = '${existing.searchEngineType}, ${result.searchEngineType}';

        deduplicated[docId] = existing.copyWith(
          score: highestScore,
          snippet: bestSnippet,
          highlights: mergedHighlights,
          matchReason: bestReason,
          searchEngineType: combinedEngines,
        );
      }
    }

    return deduplicated.values.toList();
  }
}
