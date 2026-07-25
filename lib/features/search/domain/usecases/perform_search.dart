import '../entities/search_query.dart';
import '../entities/search_result.dart';
import '../entities/search_event.dart';
import '../entities/search_statistics.dart';
import '../engines/abstract_hybrid_search_orchestrator.dart';
import '../repositories/search_event_bus.dart';
import '../repositories/search_logger.dart';
import '../cache/abstract_search_cache.dart';
import '../services/search_query_normalizer.dart';
import '../entities/optimization/search_cache_key.dart';
import 'package:uuid/uuid.dart';

/// Orchestrator use case for the full search pipeline:
///   Cache → Orchestrator → Cache → Log
class PerformSearchUseCase {
  final AbstractHybridSearchOrchestrator _orchestrator;
  final AbstractSearchCache _searchCache;
  final SearchEventBus _eventBus;
  final SearchLogger _logger;
  final SearchQueryNormalizer _normalizer;

  PerformSearchUseCase(
    this._orchestrator,
    this._searchCache,
    this._eventBus,
    this._logger,
    this._normalizer,
  );

  Future<List<SearchResult>> call(SearchQuery query) async {
    final stopwatch = Stopwatch()..start();
    final queryId = const Uuid().v4();

    _eventBus.publish(SearchStarted(queryId: queryId, query: query));

    try {
      // 1. Normalize Query and Create Cache Key
      final normalizedQuery = _normalizer.normalize(query);
      final cacheKey = SearchCacheKey(
        normalizedKeyword: normalizedQuery.normalizedKeyword,
        filterHash: query.filter.hashCode.toString(),
        offset: query.offset,
        limit: query.limit,
      );

      // 2. Check Cache
      final cachedResults = _searchCache.get(cacheKey);
      if (cachedResults != null) {
        _eventBus.publish(CacheHit(queryId: queryId, cacheKey: cacheKey.toString()));
        stopwatch.stop();
        _recordSuccess(
          query, queryId, cachedResults, stopwatch.elapsed,
          cacheHit: true,
          documentsSearched: 0,
          candidateCount: cachedResults.length,
        );
        return cachedResults;
      }
      
      _eventBus.publish(CacheMiss(queryId: queryId, cacheKey: cacheKey.toString()));

      // 3. Perform Search via Orchestrator (returns fully ranked/filtered results)
      final finalResults = await _orchestrator.search(query);

      // 4. Cache
      _searchCache.put(cacheKey, finalResults);

      stopwatch.stop();
      _recordSuccess(
        query, queryId, finalResults, stopwatch.elapsed,
        cacheHit: false,
        documentsSearched: finalResults.length,
        candidateCount: finalResults.length,
        rankingDuration: Duration.zero, // Tracked internally by orchestrator now
      );

      return finalResults;
    } catch (e) {
      stopwatch.stop();
      _eventBus.publish(SearchFailed(queryId: queryId, error: e.toString()));
      _logger.logFailure(query, e.toString());
      rethrow;
    }
  }

  void _recordSuccess(
    SearchQuery query,
    String queryId,
    List<SearchResult> results,
    Duration duration, {
    required bool cacheHit,
    required int documentsSearched,
    required int candidateCount,
    Duration? rankingDuration,
  }) {
    final stats = SearchStatistics(
      searchDuration: duration,
      resultCount: results.length,
      cacheHit: cacheHit,
      engineUsed: 'hybrid_orchestrator',
      documentsSearched: documentsSearched,
      candidateCount: candidateCount,
      rankingDuration: rankingDuration,
    );

    _eventBus.publish(SearchCompleted(
      queryId: queryId,
      resultCount: stats.resultCount,
      duration: stats.searchDuration,
      cacheHit: stats.cacheHit,
      engineUsed: stats.engineUsed,
    ));

    _logger.logSearch(query, stats);
  }
}
