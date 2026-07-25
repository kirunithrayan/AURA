class SearchHealthReport {
  final int architectureScore;
  final int performanceScore;
  final int securityScore;
  final int maintainabilityScore;
  final String technicalDebtLevel;
  final bool productionReady;
  final DateTime generatedAt;
  final List<String> recommendations;

  const SearchHealthReport({
    required this.architectureScore,
    required this.performanceScore,
    required this.securityScore,
    required this.maintainabilityScore,
    required this.technicalDebtLevel,
    required this.productionReady,
    required this.generatedAt,
    required this.recommendations,
  });
}
