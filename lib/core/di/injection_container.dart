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

  // ---------------------------------------------------------------------------
  // 5. Repositories
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      localDataSource: sl(),
      fileService: sl(),
      thumbnailService: sl(),
    ),
  );
}
