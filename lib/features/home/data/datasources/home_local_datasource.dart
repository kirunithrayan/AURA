import 'package:sqflite_sqlcipher/sqflite.dart' hide DatabaseException;
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../../../workspace/data/models/workspace_file_model.dart';

abstract class HomeLocalDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<WorkspaceFileModel>> getRecentDocuments(int limit);
  Future<List<WorkspaceFileModel>> getGlobalPinnedDocuments();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {

  HomeLocalDataSourceImpl(this.dbHelper);
  final DatabaseHelper dbHelper;

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final db = await dbHelper.database;
      
      final workspacesResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.workspacesTable}');
      final totalWorkspaces = Sqflite.firstIntValue(workspacesResult) ?? 0;

      final documentsResult = await db.rawQuery('SELECT SUM(file_count) as total FROM ${DbConstants.workspacesTable}');
      final totalDocuments = (documentsResult.first['total'] as int?) ?? 0;

      final storageResult = await db.rawQuery('SELECT SUM(size) as total FROM ${DbConstants.workspaceFilesTable}');
      final totalStorageUsed = (storageResult.first['total'] as int?) ?? 0;

      return DashboardStatsModel(
        totalWorkspaces: totalWorkspaces,
        totalDocuments: totalDocuments,
        totalStorageUsed: totalStorageUsed,
      );
    } catch (e) {
      throw DatabaseException('Failed to generate dashboard stats: $e');
    }
  }

  @override
  Future<List<WorkspaceFileModel>> getRecentDocuments(int limit) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return results.map(WorkspaceFileModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch recent documents: $e');
    }
  }

  @override
  Future<List<WorkspaceFileModel>> getGlobalPinnedDocuments() async {
    try {
      final db = await dbHelper.database;
      // Reads workspace_files.is_pinned directly. This used to join a
      // `pinned_documents` table that the schema never created, so the home
      // screen's pinned row threw "no such table" on every load.
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'is_pinned = 1',
        orderBy: 'created_at DESC',
      );
      return results.map(WorkspaceFileModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch global pinned documents: $e');
    }
  }
}
