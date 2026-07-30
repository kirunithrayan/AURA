import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../../search/domain/services/search_performance_monitor.dart';
import '../../domain/entities/diagnostics_state.dart';

final diagnosticsViewModelProvider = StateNotifierProvider.autoDispose<DiagnosticsViewModel, DiagnosticsState>(
  (ref) => DiagnosticsViewModel(
    sl<DatabaseHelper>(),
    sl<SearchPerformanceMonitor>(),
  ),
);

class DiagnosticsViewModel extends StateNotifier<DiagnosticsState> {

  DiagnosticsViewModel(this._dbHelper, this._performanceMonitor) : super(const DiagnosticsState()) {
    loadDiagnostics();
  }
  final DatabaseHelper _dbHelper;
  final SearchPerformanceMonitor _performanceMonitor;

  Future<void> loadDiagnostics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final db = await _dbHelper.database;

      // 1. Documents Indexed
      final docsResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.workspaceFilesTable}');
      final docsCount = (docsResult.first['count'] as int?) ?? 0;

      // 2. Embedding Count
      final embedResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.embeddingsTable}');
      final embedCount = (embedResult.first['count'] as int?) ?? 0;

      // 3. Knowledge Nodes
      final nodesResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.knowledgeNodesTable}');
      final nodesCount = (nodesResult.first['count'] as int?) ?? 0;

      // 4. Knowledge Edges
      final edgesResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.knowledgeEdgesTable}');
      final edgesCount = (edgesResult.first['count'] as int?) ?? 0;

      // 5. Database Size
      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = join(docsDir.path, DbConstants.databaseName);
      final dbFile = File(dbPath);
      final dbSize = await dbFile.exists() ? await dbFile.length() : 0;

      // 6. Search Performance Metrics
      final snapshot = _performanceMonitor.getSnapshot();

      state = state.copyWith(
        documentsIndexed: docsCount,
        embeddingCount: embedCount,
        cacheHits: snapshot.cacheHits,
        cacheMisses: snapshot.cacheMisses,
        averageSearchTime: snapshot.averageQueryTime,
        averageIndexingTime: snapshot.averageIndexingDuration,
        knowledgeNodes: nodesCount,
        knowledgeEdges: edgesCount,
        databaseSizeBytes: dbSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load diagnostics: $e',
      );
    }
  }
}
