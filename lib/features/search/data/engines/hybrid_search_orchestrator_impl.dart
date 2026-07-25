import '../../domain/engines/abstract_hybrid_search_orchestrator.dart';
import '../../domain/engines/abstract_search_engine_registry.dart';
import '../../domain/engines/abstract_merge_strategy.dart';
import '../../domain/engines/abstract_duplicate_resolver.dart';
import '../../domain/engines/abstract_score_normalizer.dart';
import '../../data/engines/filter/filter_engine.dart';
import '../../domain/engines/abstract_ranking_engine.dart';
import '../../domain/engines/abstract_search_post_processor.dart';
import '../../domain/repositories/search_event_bus.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/search_event.dart';
import '../../domain/entities/search_execution_context.dart';
import '../../domain/entities/search_execution_policy.dart';

class HybridSearchOrchestratorImpl implements AbstractHybridSearchOrchestrator {
  final AbstractSearchEngineRegistry _registry;
  final AbstractMergeStrategy _mergeStrategy;
  final AbstractDuplicateResolver _duplicateResolver;
  final AbstractScoreNormalizer _scoreNormalizer;
  final AbstractFilterEngine _filterEngine;
  final AbstractRankingEngine _rankingEngine;
  final AbstractSearchPostProcessor _postProcessor;
  final SearchEventBus _eventBus;
  final SearchExecutionPolicy _policy;

  HybridSearchOrchestratorImpl({
    required AbstractSearchEngineRegistry registry,
    required AbstractMergeStrategy mergeStrategy,
    required AbstractDuplicateResolver duplicateResolver,
    required AbstractScoreNormalizer scoreNormalizer,
    required AbstractFilterEngine filterEngine,
    required AbstractRankingEngine rankingEngine,
    required AbstractSearchPostProcessor postProcessor,
    required SearchEventBus eventBus,
    SearchExecutionPolicy policy = SearchExecutionPolicy.sequential,
  })  : _registry = registry,
        _mergeStrategy = mergeStrategy,
        _duplicateResolver = duplicateResolver,
        _scoreNormalizer = scoreNormalizer,
        _filterEngine = filterEngine,
        _rankingEngine = rankingEngine,
        _postProcessor = postProcessor,
        _eventBus = eventBus,
        _policy = policy;

  @override
  Future<List<SearchResult>> search(SearchQuery query) async {
    final queryId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final activeEngines = _registry.getActiveEngines();
    
    var context = SearchExecutionContext(
      query: query,
      activeEngines: activeEngines,
    );

    if (activeEngines.isEmpty) return [];

    final engineResultsList = <List<SearchResult>>[];
    final engineDurations = <String, Duration>{};

    // Execution
    if (_policy == SearchExecutionPolicy.sequential || _policy == SearchExecutionPolicy.futureAdaptive) {
      for (final descriptor in activeEngines) {
        _eventBus.publish(EngineStarted(queryId: queryId, engineId: descriptor.id));
        
        final stopwatch = Stopwatch()..start();
        try {
          final results = await descriptor.engine.search(query);
          stopwatch.stop();
          
          engineResultsList.add(results);
          engineDurations[descriptor.id] = stopwatch.elapsed;
          
          _eventBus.publish(EngineCompleted(
            queryId: queryId, 
            engineId: descriptor.id, 
            resultCount: results.length,
            duration: stopwatch.elapsed,
          ));
        } catch (e) {
          stopwatch.stop();
          _eventBus.publish(EngineFailed(
            queryId: queryId, 
            engineId: descriptor.id, 
            error: e.toString(),
          ));
        }
      }
    } else {
      // Parallel execution
      final futures = activeEngines.map((descriptor) async {
        _eventBus.publish(EngineStarted(queryId: queryId, engineId: descriptor.id));
        final stopwatch = Stopwatch()..start();
        try {
          final results = await descriptor.engine.search(query);
          stopwatch.stop();
          
          _eventBus.publish(EngineCompleted(
            queryId: queryId, 
            engineId: descriptor.id, 
            resultCount: results.length,
            duration: stopwatch.elapsed,
          ));
          return MapEntry(descriptor.id, {'results': results, 'duration': stopwatch.elapsed});
        } catch (e) {
          stopwatch.stop();
          _eventBus.publish(EngineFailed(
            queryId: queryId, 
            engineId: descriptor.id, 
            error: e.toString(),
          ));
          return null;
        }
      });

      final completed = await Future.wait(futures);
      for (final result in completed) {
        if (result != null) {
          engineResultsList.add(result.value['results'] as List<SearchResult>);
          engineDurations[result.key] = result.value['duration'] as Duration;
        }
      }
    }

    _eventBus.publish(MergeStarted(queryId: queryId, engineCount: engineResultsList.length));
    final mergeStopwatch = Stopwatch()..start();

    // Normalization per engine result
    final normalizedResultsList = engineResultsList.map((res) => _scoreNormalizer.normalize(res)).toList();

    // Merging
    final mergedResults = _mergeStrategy.merge(normalizedResultsList);
    final totalResultsBeforeMerge = mergedResults.length;

    // Duplicates
    final deduplicatedResults = _duplicateResolver.resolve(mergedResults);
    
    // Filtering
    final filteredResults = _filterEngine.filter(query, deduplicatedResults);
    
    mergeStopwatch.stop();
    _eventBus.publish(MergeCompleted(
      queryId: queryId, 
      totalResultsBeforeMerge: totalResultsBeforeMerge,
      finalResultCount: filteredResults.length,
      duration: mergeStopwatch.elapsed,
    ));

    context = context.copyWith(
      mergedResults: filteredResults,
      engineDurations: engineDurations,
      duplicateCount: totalResultsBeforeMerge - deduplicatedResults.length, // approximation
    );

    // Ranking
    final rankedResults = _rankingEngine.rank(query, filteredResults);

    // Post processing
    final finalResults = await _postProcessor.process(context, rankedResults);

    return finalResults;
  }
}
