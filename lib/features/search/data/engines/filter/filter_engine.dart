import '../../../domain/entities/search_query.dart';
import '../../../domain/entities/search_result.dart';

/// Contract for post-search filtering of candidate results.
abstract class AbstractFilterEngine {
  List<SearchResult> filter(SearchQuery query, List<SearchResult> candidates);
}

/// Default filter engine applying workspace, file type, favorites, pinned,
/// and date range filters on candidate results.
class DefaultFilterEngine implements AbstractFilterEngine {
  const DefaultFilterEngine();

  @override
  List<SearchResult> filter(SearchQuery query, List<SearchResult> candidates) {
    var filtered = candidates;

    // Filter by workspace
    if (query.workspaceId != null) {
      filtered = filtered
          .where((r) => r.metadata.workspaceId == query.workspaceId)
          .toList();
    }

    // Filter by file types
    if (query.filter.fileTypes.isNotEmpty) {
      filtered = filtered
          .where((r) => query.filter.fileTypes.contains(r.metadata.fileExtension))
          .toList();
    }

    // Filter by favorites
    if (query.filter.favoritesOnly) {
      filtered = filtered
          .where((r) => r.metadata.isFavorite)
          .toList();
    }

    // Filter by pinned
    if (query.filter.pinnedOnly) {
      filtered = filtered
          .where((r) => r.metadata.isPinned)
          .toList();
    }

    // Filter by date range (createdAt)
    if (query.filter.startDate != null) {
      final startMs = query.filter.startDate!.millisecondsSinceEpoch;
      filtered = filtered
          .where((r) => r.metadata.createdAt >= startMs)
          .toList();
    }
    if (query.filter.endDate != null) {
      final endMs = query.filter.endDate!.millisecondsSinceEpoch;
      filtered = filtered
          .where((r) => r.metadata.createdAt <= endMs)
          .toList();
    }

    return filtered;
  }
}
