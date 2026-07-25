import 'dart:async';
import '../../domain/entities/optimization/performance_snapshot.dart';
import '../../domain/services/search_performance_monitor.dart';
import '../../domain/repositories/search_event_bus.dart';
import '../../domain/entities/search_event.dart';
import '../../domain/entities/indexing/search_index_event.dart';

class SearchPerformanceMonitorImpl implements SearchPerformanceMonitor {
  final SearchEventBus _eventBus;
  StreamSubscription? _subscription;

  int _totalQueries = 0;
  int _totalQueryDurationMs = 0;

  int _totalIndexes = 0;
  int _totalIndexDurationMs = 0;

  int _cacheHits = 0;
  int _cacheMisses = 0;

  int _totalRankingDurationMs = 0;
  int _totalMergeDurationMs = 0;
  
  SearchPerformanceMonitorImpl(this._eventBus) {
    _subscription = _eventBus.events.listen(_onEvent);
  }

  void _onEvent(SearchEvent event) {
    if (event is SearchCompleted) {
      _totalQueries++;
      _totalQueryDurationMs += event.duration.inMilliseconds;
    } else if (event is IndexCompleted) {
      _totalIndexes++;
      _totalIndexDurationMs += event.statistics.indexDuration.inMilliseconds;
    } else if (event is CacheHit) {
      _cacheHits++;
    } else if (event is CacheMiss) {
      _cacheMisses++;
    } else if (event is MergeCompleted) {
      _totalMergeDurationMs += event.duration.inMilliseconds;
    }
  }

  @override
  PerformanceSnapshot getSnapshot() {
    return PerformanceSnapshot(
      averageQueryTime: _totalQueries > 0 
          ? Duration(milliseconds: _totalQueryDurationMs ~/ _totalQueries)
          : Duration.zero,
      averageIndexingDuration: _totalIndexes > 0 
          ? Duration(milliseconds: _totalIndexDurationMs ~/ _totalIndexes)
          : Duration.zero,
      cacheHitRate: (_cacheHits + _cacheMisses) > 0 
          ? _cacheHits / (_cacheHits + _cacheMisses)
          : 0.0,
      averageRankingDuration: _totalQueries > 0 
          ? Duration(milliseconds: _totalRankingDurationMs ~/ _totalQueries)
          : Duration.zero,
      averageMergeDuration: _totalQueries > 0 
          ? Duration(milliseconds: _totalMergeDurationMs ~/ _totalQueries)
          : Duration.zero,
      averageDeduplicationDuration: Duration.zero, // Add deduplication events if needed
      estimatedMemoryUsageBytes: _cacheHits * 1024, // Mock memory estimation
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
