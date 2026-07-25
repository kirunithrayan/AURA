import 'package:equatable/equatable.dart';

class SearchStatistics extends Equatable {
  final Duration searchDuration;
  final int resultCount;
  final bool cacheHit;
  final String engineUsed;
  final int documentsSearched;
  final int candidateCount;
  final Duration? rankingDuration;

  // New orchestrator stats
  final int enginesExecuted;
  final Map<String, Duration> executionTimePerEngine;
  final Duration mergeDuration;
  final int duplicateCount;

  const SearchStatistics({
    required this.searchDuration,
    required this.resultCount,
    required this.cacheHit,
    required this.engineUsed,
    this.documentsSearched = 0,
    this.candidateCount = 0,
    this.rankingDuration,
    this.enginesExecuted = 1,
    this.executionTimePerEngine = const {},
    this.mergeDuration = Duration.zero,
    this.duplicateCount = 0,
  });

  @override
  List<Object?> get props => [
        searchDuration,
        resultCount,
        cacheHit,
        engineUsed,
        documentsSearched,
        candidateCount,
        rankingDuration,
        enginesExecuted,
        executionTimePerEngine,
        mergeDuration,
        duplicateCount,
      ];
}
