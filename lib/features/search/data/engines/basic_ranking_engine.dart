import '../../domain/engines/abstract_ranking_engine.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';

/// Production ranking engine with multi-factor scoring.
///
/// Ranking factors:
/// - Base relevance score from matching (frequency, exact/prefix/phrase)
/// - Document recency boost
/// - Favorite boost
/// - Pinned boost
///
/// Sorting can be overridden by the query's sortField.
class BasicRankingEngine implements AbstractRankingEngine {
  static const double _favoriteBoost = 1.2;
  static const double _pinnedBoost = 1.15;
  static const double _recencyMaxBoost = 1.3;
  static const int _recencyWindowDays = 30;

  @override
  Future<List<SearchResult>> rank(SearchQuery query, List<SearchResult> candidates) async {
    if (candidates.isEmpty) return candidates;

    // Apply boosted scoring
    final boosted = candidates.map((result) {
      double adjustedScore = result.score;

      // Favorite boost
      if (result.metadata.isFavorite) {
        adjustedScore *= _favoriteBoost;
      }

      // Pinned boost
      if (result.metadata.isPinned) {
        adjustedScore *= _pinnedBoost;
      }

      // Recency boost (linear decay over window)
      final now = DateTime.now().millisecondsSinceEpoch;
      final docAge = now - result.metadata.modifiedAt;
      const windowMs = _recencyWindowDays * 24 * 60 * 60 * 1000;
      if (docAge < windowMs) {
        final recencyFactor = 1.0 - (docAge / windowMs);
        adjustedScore *= (1.0 + (recencyFactor * (_recencyMaxBoost - 1.0)));
      }

      return result.copyWith(score: adjustedScore);
    }).toList();

    // Sort
    if (query.sortField == 'date') {
      boosted.sort((a, b) => query.ascending
          ? a.metadata.createdAt.compareTo(b.metadata.createdAt)
          : b.metadata.createdAt.compareTo(a.metadata.createdAt));
    } else if (query.sortField == 'name') {
      boosted.sort((a, b) => query.ascending
          ? a.metadata.fileName.compareTo(b.metadata.fileName)
          : b.metadata.fileName.compareTo(a.metadata.fileName));
    } else {
      // Default: sort by score descending
      boosted.sort((a, b) => query.ascending
          ? a.score.compareTo(b.score)
          : b.score.compareTo(a.score));
    }

    return boosted;
  }
}
