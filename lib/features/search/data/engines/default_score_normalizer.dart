import 'dart:math';
import '../../domain/engines/abstract_score_normalizer.dart';
import '../../domain/entities/search_result.dart';

class DefaultScoreNormalizer implements AbstractScoreNormalizer {
  @override
  List<SearchResult> normalize(List<SearchResult> results) {
    if (results.isEmpty) return results;

    double minScore = double.infinity;
    double maxScore = double.negativeInfinity;

    for (final result in results) {
      minScore = min(minScore, result.score);
      maxScore = max(maxScore, result.score);
    }

    if (maxScore == minScore) {
      return results; 
    }

    return results.map((result) {
      final normalizedScore = (result.score - minScore) / (maxScore - minScore);
      return result.copyWith(score: normalizedScore);
    }).toList();
  }
}
