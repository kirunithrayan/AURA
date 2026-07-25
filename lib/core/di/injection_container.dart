import 'package:get_it/get_it.dart';

// Core
import '../database/database_helper.dart';

// Services
import '../../services/file_service.dart';
import '../../services/thumbnail_service.dart';
import '../../services/battery_service.dart';
import '../../services/thermal_service.dart';
import '../../services/memory_service.dart';
import '../../services/workmanager_service.dart';

// AI Abstraction Layer
import '../../ai/engine/embedding_config.dart';
import '../../ai/engine/embedding_engine.dart';
import '../../ai/engine/embedding_engine_mock.dart';
import '../../ai/retrieval/retrieval_engine.dart';
import '../../ai/retrieval/retrieval_engine_impl.dart';
import '../../ai/providers/ai_provider.dart';
import '../../ai/providers/ai_provider_local.dart';

// Features - Home
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';

// Features - Workspace
import '../../features/workspace/data/datasources/workspace_local_datasource.dart';
import '../../features/workspace/domain/repositories/workspace_repository.dart';
import '../../features/workspace/data/repositories/workspace_repository_impl.dart';
import '../../features/workspace/domain/usecases/pin_document.dart';
import '../../features/workspace/domain/usecases/unpin_document.dart';
import '../../features/workspace/domain/usecases/import_files.dart';

// Document Viewer Imports
import '../../features/document_viewer/domain/repositories/document_viewer_repository.dart';
import '../../features/document_viewer/data/repositories/document_viewer_repository_impl.dart';
import '../../features/document_viewer/domain/usecases/get_document_for_viewing.dart';

// Document Metadata Imports
import '../../features/document_metadata/data/cache/metadata_cache.dart';
import '../../features/document_metadata/domain/services/document_metadata_service.dart';
import '../../features/document_metadata/data/services/document_metadata_service_impl.dart';
import '../../features/document_metadata/domain/services/recent_documents_service.dart';
import '../../features/document_metadata/domain/services/favorite_documents_service.dart';
import '../../features/document_metadata/domain/services/pinned_documents_service.dart';

// Search Imports
import '../../features/search/data/datasources/local_search_datasource.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_event_bus.dart';
import '../../features/search/data/repositories/search_event_bus_impl.dart';
import '../../features/search/domain/repositories/search_logger.dart';
import '../../features/search/data/repositories/search_logger_impl.dart';
import '../../features/search/data/cache/search_cache.dart';
import '../../features/search/domain/engines/abstract_ranking_engine.dart';
import '../../features/search/data/engines/basic_ranking_engine.dart';
import '../../features/search/domain/engines/abstract_search_engine.dart';
import '../../features/search/data/engines/keyword_search_engine.dart';
import '../../features/search/domain/usecases/perform_search.dart';
import '../../features/search/domain/services/search_query_normalizer.dart';
import '../../features/search/data/services/search_query_normalizer_impl.dart';
import '../../features/search/domain/services/batch_indexing_service.dart';
import '../../features/search/data/indexing/batch_indexing_service_impl.dart';
import '../../features/search/domain/services/search_performance_monitor.dart';
import '../../features/search/data/services/search_performance_monitor_impl.dart';
import '../../features/search/domain/services/search_profiler.dart';
import '../../features/search/data/services/search_profiler_impl.dart';
// Hybrid Search Orchestrator Imports
import '../../features/search/domain/engines/abstract_search_engine_registry.dart';
import '../../features/search/domain/engines/abstract_search_engine.dart';
import '../../features/search/domain/cache/abstract_search_cache.dart';
import '../../features/search/domain/engines/abstract_hybrid_search_orchestrator.dart';
import '../../features/search/data/engines/hybrid_search_orchestrator_impl.dart';
import '../../features/search/domain/engines/abstract_merge_strategy.dart';
import '../../features/search/data/engines/highest_score_merge_strategy.dart';
import '../../features/search/domain/engines/abstract_duplicate_resolver.dart';
import '../../features/search/data/engines/default_duplicate_resolver.dart';
import '../../features/search/domain/engines/abstract_score_normalizer.dart';
import '../../features/search/data/engines/default_score_normalizer.dart';
import '../../features/search/domain/engines/abstract_search_post_processor.dart';
import '../../features/search/data/engines/default_search_post_processor.dart';
import '../../features/search/domain/entities/search_engine_descriptor.dart';
import '../../features/search/domain/entities/search_engine_capability.dart';

// Search UX Imports (History & Suggestions)
import '../../features/search/domain/repositories/search_history_repository.dart';
import '../../features/search/data/repositories/search_history_repository_impl.dart';
import '../../features/search/domain/services/search_history_service.dart';
import '../../features/search/data/services/search_history_service_impl.dart';
import '../../features/search/domain/services/search_suggestion_service.dart';
import '../../features/search/data/services/search_suggestion_service_impl.dart';
import '../../features/search/data/services/providers/history_suggestion_provider.dart';
import '../../features/search/data/services/providers/frequent_term_suggestion_provider.dart';

import '../../core/text_engine/abstract_text_document_engine.dart';
import '../../core/text_engine/text_engine_impl.dart';
import '../../features/document_viewer/data/cache/document_cache.dart';

// Search Indexing Imports
import '../../features/search/data/indexing/tokenizer/abstract_tokenizer.dart';
import '../../features/search/data/indexing/tokenizer/default_tokenizer.dart';
import '../../features/search/data/indexing/normalizer/abstract_token_normalizer.dart';
import '../../features/search/data/indexing/normalizer/default_token_normalizer.dart';
import '../../features/search/data/indexing/filter/abstract_stop_word_filter.dart';
import '../../features/search/data/indexing/filter/default_stop_word_filter.dart';
import '../../features/search/data/indexing/builder/abstract_index_builder.dart';
import '../../features/search/data/indexing/builder/default_index_builder.dart';
import '../../features/search/data/indexing/datasources/search_index_local_datasource.dart';
import '../../features/search/data/indexing/repositories/search_index_repository.dart';
import '../../features/search/data/indexing/repositories/search_index_repository_impl.dart';
import '../../features/search/data/indexing/cache/search_index_cache.dart';
import '../../features/search/data/indexing/search_index_logger.dart';
import '../../features/search/data/indexing/search_index_service.dart';
import '../../features/search/domain/entities/optimization/search_cache_configuration.dart';

// Search Engine Pipeline (Module 5.3)
import '../../features/search/data/engines/query/query_processor.dart';
import '../../features/search/data/engines/matching/matching_strategy.dart';
import '../../features/search/data/engines/filter/filter_engine.dart';
import '../../features/search/data/engines/snippet/search_snippet_generator.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes the dependency injection container.
/// This registers Singletons for background/core tasks. 
/// Riverpod will wrap these via Providers for UI access.
Future<void> initInjection() async {
  // ---------------------------------------------------------------------------
  // 1. Core / Database
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // ---------------------------------------------------------------------------
  // 2. Services
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<FileService>(() => FileService());
  sl.registerLazySingleton<ThumbnailService>(() => ThumbnailService());
  sl.registerLazySingleton<BatteryService>(() => BatteryService());
  sl.registerLazySingleton<ThermalService>(() => ThermalService());
  sl.registerLazySingleton<MemoryService>(() => MemoryService());
  sl.registerLazySingleton<WorkManagerService>(() => WorkManagerService());

  // Document Metadata Cache and Services
  sl.registerLazySingleton<MetadataCache>(() => MetadataCache());
  
  sl.registerLazySingleton<DocumentMetadataService>(
    () => DocumentMetadataServiceImpl(sl(), sl()),
  );
  
  sl.registerLazySingleton<RecentDocumentsService>(
    () => RecentDocumentsService(sl(), sl()),
  );
  
  sl.registerLazySingleton<FavoriteDocumentsService>(
    () => FavoriteDocumentsService(sl(), sl()),
  );
  
  sl.registerLazySingleton<PinnedDocumentsService>(
    () => PinnedDocumentsService(sl(), sl()),
  );

  // ---------------------------------------------------------------------------
  // 3. AI Interfaces & Engines
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<EmbeddingConfig>(() => const EmbeddingConfig(
    modelPath: 'assets/models/stub.onnx',
    modelVersion: 'mock_v1',
  ));

  sl.registerLazySingleton<EmbeddingEngine>(
    () => MockEmbeddingEngine(),
  );

  sl.registerLazySingleton<RetrievalEngine>(
    () => RetrievalEngineImpl(embeddingEngine: sl()),
  );

  sl.registerLazySingleton<AIProvider>(
    () => LocalRetrievalProvider(),
  );

  // ---------------------------------------------------------------------------
  // 4. Data Sources
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sl()),
  );
  
  sl.registerLazySingleton<WorkspaceLocalDataSource>(
    () => WorkspaceLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<LocalSearchDatasource>(
    () => LocalSearchDatasource(sl()),
  );

  // Performance & Caching
  sl.registerLazySingleton<SearchCacheConfiguration>(
    () => const SearchCacheConfiguration(enableMetrics: true),
  );
  
  sl.registerLazySingleton<AbstractSearchCache>(
    () => SearchCache(sl()),
  );
  
  sl.registerLazySingleton<DocumentCache>(() => DocumentCache());
  
  // Text Engine
  sl.registerLazySingleton<AbstractTextDocumentEngine>(
    () => TextEngineImpl(sl()),
  );

  // ---------------------------------------------------------------------------
  // 5. Repositories
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<DocumentViewerRepository>(
    () => DocumentViewerRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      localDataSource: sl(),
      fileService: sl(),
      thumbnailService: sl(),
    ),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SearchEventBus>(
    () => SearchEventBusImpl(),
  );

  sl.registerLazySingleton<SearchLogger>(
    () => SearchLoggerImpl(),
  );

  sl.registerLazySingleton<AbstractRankingEngine>(
    () => BasicRankingEngine(),
  );

  // Search Engine Pipeline Components (Module 5.3)
  sl.registerLazySingleton<AbstractQueryProcessor>(
    () => DefaultQueryProcessor(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<AbstractMatchingStrategy>(
    () => const DefaultMatchingStrategy(),
  );

  sl.registerLazySingleton<AbstractFilterEngine>(
    () => const DefaultFilterEngine(),
  );

  sl.registerLazySingleton<SearchSnippetGenerator>(
    () => const SearchSnippetGenerator(),
  );

  sl.registerLazySingleton<AbstractSearchEngine>(
    () => KeywordSearchEngine(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  // Hybrid Search Orchestrator Pipeline
  sl.registerLazySingleton<AbstractSearchEngineRegistry>(
    () => DefaultSearchEngineRegistry(),
  );

  sl.registerLazySingleton<AbstractMergeStrategy>(
    () => HighestScoreMergeStrategy(),
  );

  sl.registerLazySingleton<AbstractDuplicateResolver>(
    () => DefaultDuplicateResolver(),
  );

  sl.registerLazySingleton<AbstractScoreNormalizer>(
    () => DefaultScoreNormalizer(),
  );

  sl.registerLazySingleton<AbstractSearchPostProcessor>(
    () => DefaultSearchPostProcessor(),
  );

  sl.registerLazySingleton<AbstractHybridSearchOrchestrator>(
    () => HybridSearchOrchestratorImpl(
      registry: sl(),
      mergeStrategy: sl(),
      duplicateResolver: sl(),
      scoreNormalizer: sl(),
      filterEngine: sl(),
      rankingEngine: sl(),
      postProcessor: sl(),
      eventBus: sl(),
    ),
  );

  // Search UX Services
  sl.registerLazySingleton<SearchHistoryRepository>(
    () => SearchHistoryRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SearchHistoryService>(
    () => SearchHistoryServiceImpl(sl()),
  );

  sl.registerLazySingleton<HistorySuggestionProvider>(
    () => HistorySuggestionProvider(sl()),
  );

  sl.registerLazySingleton<FrequentTermSuggestionProvider>(
    () => FrequentTermSuggestionProvider(sl()),
  );

  sl.registerLazySingleton<SearchSuggestionService>(
    () {
      final service = SearchSuggestionServiceImpl();
      service.registerProvider(sl<HistorySuggestionProvider>());
      service.registerProvider(sl<FrequentTermSuggestionProvider>());
      return service;
    },
  );

  // ---------------------------------------------------------------------------
  // 5b. Search Indexing Pipeline
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AbstractTokenizer>(
    () => const DefaultTokenizer(),
  );

  sl.registerLazySingleton<AbstractTokenNormalizer>(
    () => const DefaultTokenNormalizer(),
  );

  sl.registerLazySingleton<AbstractStopWordFilter>(
    () => DefaultStopWordFilter(),
  );

  sl.registerLazySingleton<AbstractIndexBuilder>(
    () => DefaultIndexBuilder(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<SearchIndexLocalDatasource>(
    () => SearchIndexLocalDatasource(sl()),
  );

  sl.registerLazySingleton<SearchIndexRepository>(
    () => SearchIndexRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SearchIndexCache>(() => SearchIndexCache());

  sl.registerLazySingleton<SearchIndexLogger>(
    () => const SearchIndexLoggerImpl(),
  );

  sl.registerLazySingleton<SearchIndexService>(
    () => SearchIndexService(sl(), sl(), sl(), sl(), sl(), sl()),
  );

  sl.registerLazySingleton<BatchIndexingService>(
    () => BatchIndexingServiceImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<SearchPerformanceMonitor>(
    () => SearchPerformanceMonitorImpl(sl()),
  );

  sl.registerLazySingleton<SearchProfiler>(
    () => SearchProfilerImpl(sl()),
  );

  // ---------------------------------------------------------------------------
  // 6. Use Cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => GetDocumentForViewing(sl()));

  sl.registerLazySingleton<SearchQueryNormalizer>(
    () => SearchQueryNormalizerImpl(),
  );

  sl.registerLazySingleton(() => PerformSearchUseCase(
    sl(),
    sl(),
    sl(),
    sl(),
    sl(),
  ));

  // Register default engines with the Orchestrator's Registry
  final registry = sl<AbstractSearchEngineRegistry>();
  final keywordEngine = sl<AbstractSearchEngine>();
  
  registry.registerEngine(SearchEngineDescriptor(
    id: 'keyword_engine',
    name: 'Keyword Search Engine',
    capabilities: {SearchEngineCapability.keyword},
    engine: keywordEngine,
  ));
}
