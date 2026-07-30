class PersonalizationScore {

  const PersonalizationScore({
    required this.readingScore,
    required this.searchScore,
    required this.favoriteBoost,
    required this.recencyBoost,
    required this.finalScore,
  });

  factory PersonalizationScore.empty() => const PersonalizationScore(
      readingScore: 0.0,
      searchScore: 0.0,
      favoriteBoost: 1.0,
      recencyBoost: 1.0,
      finalScore: 0.0,
    );
  final double readingScore;
  final double searchScore;
  final double favoriteBoost;
  final double recencyBoost;
  final double finalScore;
}
