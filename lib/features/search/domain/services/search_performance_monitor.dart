import '../entities/optimization/performance_snapshot.dart';

abstract class SearchPerformanceMonitor {
  /// Returns the current aggregated performance statistics snapshot.
  PerformanceSnapshot getSnapshot();
}
