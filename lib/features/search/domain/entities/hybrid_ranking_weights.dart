import 'package:equatable/equatable.dart';

/// Configuration object for hybrid ranking weights.
class HybridRankingWeights extends Equatable {

  const HybridRankingWeights({
    this.semanticWeight = 0.6,
    this.keywordWeight = 0.4,
    this.recencyBoost = 1.2,
    this.favoriteBoost = 1.2,
    this.activityBoost = 1.1,
    this.personalizationWeight = 0.3,
  });
  final double semanticWeight;
  final double keywordWeight;
  final double recencyBoost;
  final double favoriteBoost;
  final double activityBoost;
  final double personalizationWeight;

  @override
  List<Object?> get props => [
        semanticWeight,
        keywordWeight,
        recencyBoost,
        favoriteBoost,
        activityBoost,
        personalizationWeight,
      ];
}
