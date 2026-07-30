import 'package:equatable/equatable.dart';

class PerformanceSnapshot extends Equatable {

  const PerformanceSnapshot({
    required this.averageQueryTime,
    required this.averageIndexingDuration,
    required this.cacheHitRate,
    required this.cacheHits,
    required this.cacheMisses,
    required this.averageRankingDuration,
    required this.averageMergeDuration,
    required this.averageDeduplicationDuration,
  });
  final Duration averageQueryTime;
  final Duration averageIndexingDuration;
  final double cacheHitRate;
  final int cacheHits;
  final int cacheMisses;
  final Duration averageRankingDuration;
  final Duration averageMergeDuration;
  final Duration averageDeduplicationDuration;

  @override
  List<Object?> get props => [
        averageQueryTime,
        averageIndexingDuration,
        cacheHitRate,
        cacheHits,
        cacheMisses,
        averageRankingDuration,
        averageMergeDuration,
        averageDeduplicationDuration,
      ];
}
