import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'injection_container.dart';

// Services
import '../../services/file_service.dart';
import '../../services/battery_service.dart';

// AI
import '../../ai/retrieval/retrieval_engine.dart';
import '../../ai/providers/ai_provider.dart';

// Repositories
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/workspace/domain/repositories/workspace_repository.dart';

/// Riverpod Providers for bridging GetIt singletons into the widget tree.
/// This ensures ViewModels can cleanly `ref.watch` or `ref.read` dependencies
/// while keeping background isolation (WorkManager) reliant purely on GetIt.

// --- Services ---
final fileServiceProvider = Provider<FileService>((ref) => sl<FileService>());
final batteryServiceProvider = Provider<BatteryService>((ref) => sl<BatteryService>());

// --- AI Interfaces ---
final retrievalEngineProvider = Provider<RetrievalEngine>((ref) => sl<RetrievalEngine>());
final aiProvider = Provider<AIProvider>((ref) => sl<AIProvider>());

// --- Repositories ---
final homeRepositoryProvider = Provider<HomeRepository>((ref) => sl<HomeRepository>());
final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) => sl<WorkspaceRepository>());
