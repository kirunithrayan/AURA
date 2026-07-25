import '../entities/search_query.dart';
import '../entities/search_statistics.dart';
import '../entities/search_log_context.dart';

abstract class SearchLogger {
  /// Logs the execution of a search operation.
  Future<void> logSearch(SearchQuery query, SearchStatistics stats);

  /// Logs a failed search operation.
  Future<void> logFailure(SearchQuery query, String error);

  /// Logs a cache hit or miss.
  Future<void> logCacheEvent(String queryId, String cacheKey, bool hit);

  /// Logs optimization and profiling statistics.
  Future<void> logOptimization(String type, Duration duration, Map<String, dynamic> meta);

  /// Logs batch indexing progress.
  Future<void> logBatchEvent(String jobId, String status, {int? processed, int? failed, String? error});

  /// Logs a structured event with context.
  Future<void> logWithContext(SearchLogContext context, {Map<String, dynamic>? extraData, String? errorMessage});
}
