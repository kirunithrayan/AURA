import '../../domain/engines/abstract_ranking_engine.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/hybrid_ranking_weights.dart';

import '../../../ai/personalization/domain/services/personalization_engine.dart';

/// Ranks search results combining semantic, keyword, and metadata signals.
class HybridRankingEngine implements AbstractRankingEngine {

  HybridRankingEngine(this._weights, {PersonalizationEngine? personalizationEngine}) 
    : _personalizationEngine = personalizationEngine;
  final HybridRankingWeights _weights;
  final PersonalizationEngine? _personalizationEngine;
  static const int _recencyWindowDays = 30;

  @override
  Future<List<SearchResult>> rank(SearchQuery query, List<SearchResult> candidates) async {
    if (candidates.isEmpty) return candidates;

    // Apply boosted scoring
    final boosted = candidates.map((result) {
      double adjustedScore = 0.0;

      // Extract raw scores from explanation if available
      double semScore = result.explanation?.semanticScore ?? 0.0;
      double keyScore = result.explanation?.keywordScore ?? 0.0;

      // If missing explanation but we have a score, guess based on engine type
      if (semScore == 0.0 && keyScore == 0.0) {
        if (result.searchEngineType == 'semantic') {
          semScore = result.score;
        } else if (result.searchEngineType == 'keyword') {
          keyScore = result.score;
        } else {
          keyScore = result.score;
        }
      }

      // Combine scores
      adjustedScore = (semScore * _weights.semanticWeight) + (keyScore * _weights.keywordWeight);

      return result.copyWith(score: adjustedScore);
    }).toList();

    // Now apply personalization async if engine is available
    final List<SearchResult> personalizedBoosted = [];
    for (final result in boosted) {
      double finalScore = result.score;
      if (_personalizationEngine != null) {
        final pScore = await _personalizationEngine.calculateScore(
          result.metadata.id,
          isFavorite: result.metadata.isFavorite,
        );
        
        // Add the personalized score weighted
        finalScore += pScore.finalScore * _weights.personalizationWeight;
      } else {
        // Fallback if no personalization engine (e.g. tests)
        if (result.metadata.isFavorite) {
          finalScore *= _weights.favoriteBoost;
        }
        if (result.metadata.isPinned) {
          finalScore *= _weights.activityBoost;
        }
        final now = DateTime.now().millisecondsSinceEpoch;
        final docAge = now - result.metadata.modifiedAt;
        const windowMs = _recencyWindowDays * 24 * 60 * 60 * 1000;
        if (docAge < windowMs) {
          final recencyFactor = 1.0 - (docAge / windowMs);
          finalScore *= (1.0 + (recencyFactor * (_weights.recencyBoost - 1.0)));
        }
      }
      personalizedBoosted.add(result.copyWith(score: finalScore));
    }

    // Sort
    if (query.sortField == 'date') {
      personalizedBoosted.sort((a, b) => query.ascending
          ? a.metadata.createdAt.compareTo(b.metadata.createdAt)
          : b.metadata.createdAt.compareTo(a.metadata.createdAt));
    } else if (query.sortField == 'name') {
      boosted.sort((a, b) => query.ascending
          ? a.metadata.fileName.compareTo(b.metadata.fileName)
          : b.metadata.fileName.compareTo(a.metadata.fileName));
    } else {
      // Default: sort by score descending
      personalizedBoosted.sort((a, b) => query.ascending
          ? a.score.compareTo(b.score)
          : b.score.compareTo(a.score));
    }

    return personalizedBoosted;
  }
}
