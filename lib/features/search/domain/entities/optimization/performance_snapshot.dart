import 'package:equatable/equatable.dart';

class PerformanceSnapshot extends Equatable {
  final Duration averageQueryTime;
  final Duration averageIndexingDuration;
  final double cacheHitRate;
  final Duration averageRankingDuration;
  final Duration averageMergeDuration;
  final Duration averageDeduplicationDuration;
  final int estimatedMemoryUsageBytes;

  const PerformanceSnapshot({
    required this.averageQueryTime,
    required this.averageIndexingDuration,
    required this.cacheHitRate,
    required this.averageRankingDuration,
    required this.averageMergeDuration,
    required this.averageDeduplicationDuration,
    required this.estimatedMemoryUsageBytes,
  });

  @override
  List<Object?> get props => [
        averageQueryTime,
        averageIndexingDuration,
        cacheHitRate,
        averageRankingDuration,
        averageMergeDuration,
        averageDeduplicationDuration,
        estimatedMemoryUsageBytes,
      ];
}
