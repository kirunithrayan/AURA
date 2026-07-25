import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_statistics.dart';
import '../../domain/entities/search_log_context.dart';
import '../../domain/repositories/search_logger.dart';

class SearchLoggerImpl implements SearchLogger {
  @override
  Future<void> logSearch(SearchQuery query, SearchStatistics stats) async {
    AppLogger.info(
      'SearchCompleted | '
      'Engine: ${stats.engineUsed} | '
      'Keyword: "${query.keyword}" | '
      'Searched: ${stats.documentsSearched} | '
      'Candidates: ${stats.candidateCount} | '
      'Results: ${stats.resultCount} | '
      'Duration: ${stats.searchDuration.inMilliseconds}ms | '
      'Ranking: ${stats.rankingDuration?.inMilliseconds ?? 0}ms | '
      'EnginesExecuted: ${stats.enginesExecuted} | '
      'MergeDuration: ${stats.mergeDuration.inMilliseconds}ms | '
      'Duplicates: ${stats.duplicateCount} | '
      'CacheHit: ${stats.cacheHit}'
    );
  }

  @override
  Future<void> logFailure(SearchQuery query, String error) async {
    AppLogger.error(
      'SearchFailed | Keyword: "${query.keyword}"',
      error,
    );
  }

  @override
  Future<void> logCacheEvent(String queryId, String cacheKey, bool hit) async {
    AppLogger.info(
      'CacheEvent | Action: ${hit ? "CACHE_HIT" : "CACHE_MISS"} | '
      'QueryId: $queryId | CacheKey: $cacheKey'
    );
  }

  @override
  Future<void> logOptimization(String type, Duration duration, Map<String, dynamic> meta) async {
    AppLogger.info(
      'OptimizationEvent | Action: OPTIMIZATION_$type | '
      'Duration: ${duration.inMilliseconds}ms | Meta: $meta'
    );
  }

  @override
  Future<void> logBatchEvent(String jobId, String status, {int? processed, int? failed, String? error}) async {
    final msg = 'BatchIndexEvent | Action: BATCH_INDEX_$status | '
        'JobId: $jobId | Processed: $processed | Failed: $failed | Error: $error';
    if (error != null) {
      AppLogger.error(msg, error);
    } else {
      AppLogger.info(msg);
    }
  }

  @override
  Future<void> logWithContext(SearchLogContext context, {Map<String, dynamic>? extraData, String? errorMessage}) async {
    final map = context.toMap();
    if (extraData != null) {
      map['extra'] = extraData;
    }
    
    final msg = 'SearchLogContext | ${map.toString()}';
    
    if (!context.success || errorMessage != null) {
      AppLogger.error(msg, errorMessage ?? 'Operation failed');
    } else {
      AppLogger.info(msg);
    }
  }
}
