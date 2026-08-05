import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workspace_model.dart';
import '../models/workspace_file_model.dart';

abstract class WorkspaceLocalDataSource {
  Future<List<WorkspaceModel>> getWorkspaces();
  Future<WorkspaceModel> getWorkspaceById(String id);
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace);
  Future<WorkspaceModel> updateWorkspace(WorkspaceModel workspace);
  Future<void> deleteWorkspace(String id);

  Future<WorkspaceFileModel> getFileById(String fileId);
  Future<List<WorkspaceFileModel>> getWorkspaceFiles(String workspaceId);
  Future<WorkspaceFileModel> addFile(WorkspaceFileModel file);
  Future<void> updateFileViewerState(String fileId, {int? lastOpenedAt, int? lastViewedPage, double? lastZoomLevel, double? lastScrollPosition});
  Future<void> removeFile(String id);

  Future<List<WorkspaceFileModel>> getPinnedDocuments(String workspaceId);
  Future<void> pinDocument(String fileId, String workspaceId);
  Future<void> unpinDocument(String fileId, String workspaceId);
}

class WorkspaceLocalDataSourceImpl implements WorkspaceLocalDataSource {

  WorkspaceLocalDataSourceImpl(this.dbHelper);
  final DatabaseHelper dbHelper;

  @override
  Future<List<WorkspaceModel>> getWorkspaces() async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspacesTable,
        orderBy: 'created_at DESC',
      );
      return results.map(WorkspaceModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get workspaces: $e');
    }
  }

  @override
  Future<WorkspaceModel> getWorkspaceById(String id) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspacesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) throw const NotFoundException('Workspace not found');
      return WorkspaceModel.fromMap(results.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to get workspace: $e');
    }
  }

  @override
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    try {
      final db = await dbHelper.database;
      await db.insert(DbConstants.workspacesTable, workspace.toMap());
      return workspace;
    } catch (e) {
      throw DatabaseException('Failed to create workspace: $e');
    }
  }

  @override
  Future<WorkspaceModel> updateWorkspace(WorkspaceModel workspace) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        DbConstants.workspacesTable,
        workspace.toMap(),
        where: 'id = ?',
        whereArgs: [workspace.id],
      );
      return workspace;
    } catch (e) {
      throw DatabaseException('Failed to update workspace: $e');
    }
  }

  @override
  Future<void> deleteWorkspace(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        DbConstants.workspacesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete workspace: $e');
    }
  }

  @override
  Future<WorkspaceFileModel> getFileById(String fileId) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'id = ?',
        whereArgs: [fileId],
      );
      if (results.isEmpty) throw const NotFoundException('File not found');
      return WorkspaceFileModel.fromMap(results.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to get file: $e');
    }
  }

  @override
  Future<List<WorkspaceFileModel>> getWorkspaceFiles(String workspaceId) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'workspace_id = ?',
        whereArgs: [workspaceId],
        orderBy: 'created_at DESC',
      );
      return results.map(WorkspaceFileModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get workspace files: $e');
    }
  }

  @override
  Future<WorkspaceFileModel> addFile(WorkspaceFileModel file) async {
    try {
      final db = await dbHelper.database;
      await db.insert(DbConstants.workspaceFilesTable, file.toMap());
      
      await db.rawUpdate('''
        UPDATE ${DbConstants.workspacesTable} 
        SET file_count = file_count + 1, 
            total_size = total_size + ? 
        WHERE id = ?
      ''', [file.size ?? 0, file.workspaceId]);
      
      return file;
    } catch (e) {
      throw DatabaseException('Failed to add file: $e');
    }
  }

  @override
  Future<void> updateFileViewerState(String fileId, {int? lastOpenedAt, int? lastViewedPage, double? lastZoomLevel, double? lastScrollPosition}) async {
    try {
      final db = await dbHelper.database;
      final Map<String, dynamic> updates = {};
      if (lastOpenedAt != null) updates['last_opened_at'] = lastOpenedAt;
      if (lastViewedPage != null) updates['last_viewed_page'] = lastViewedPage;
      if (lastZoomLevel != null) updates['last_zoom_level'] = lastZoomLevel;
      if (lastScrollPosition != null) updates['last_scroll_position'] = lastScrollPosition;
      
      if (updates.isEmpty) return;
      
      await db.update(
        DbConstants.workspaceFilesTable,
        updates,
        where: 'id = ?',
        whereArgs: [fileId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update file viewer state: $e');
    }
  }

  @override
  Future<void> removeFile(String id) async {
    try {
      final db = await dbHelper.database;
      
      final fileResult = await db.query(DbConstants.workspaceFilesTable, where: 'id = ?', whereArgs: [id]);
      if (fileResult.isNotEmpty) {
        final file = WorkspaceFileModel.fromMap(fileResult.first);
        
        await db.rawUpdate('''
          UPDATE ${DbConstants.workspacesTable} 
          SET file_count = file_count - 1, 
              total_size = total_size - ? 
          WHERE id = ?
        ''', [file.size ?? 0, file.workspaceId]);
      }

      await db.delete(
        DbConstants.workspaceFilesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to remove file: $e');
    }
  }

  // Pin state lives in workspace_files.is_pinned, the same column
  // PinnedDocumentsService reads and writes. These three methods used to go
  // through a separate `pinned_documents` join table that was never created in
  // the schema, so every pin, unpin and pinned-list load threw "no such table".
  // Keeping one column as the single source of truth also stops the workspace
  // screen and the metadata service from disagreeing about what is pinned.
  //
  // workspaceId stays in the signatures (callers pass it) and is used to scope
  // the write, so a file can never be re-pinned through the wrong workspace.

  @override
  Future<List<WorkspaceFileModel>> getPinnedDocuments(String workspaceId) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'is_pinned = 1 AND workspace_id = ?',
        whereArgs: [workspaceId],
        orderBy: 'created_at DESC',
      );

      return results.map(WorkspaceFileModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get pinned documents: $e');
    }
  }

  @override
  Future<void> pinDocument(String fileId, String workspaceId) async {
    try {
      await _setPinned(fileId, workspaceId, true);
    } catch (e) {
      throw DatabaseException('Failed to pin document: $e');
    }
  }

  @override
  Future<void> unpinDocument(String fileId, String workspaceId) async {
    try {
      await _setPinned(fileId, workspaceId, false);
    } catch (e) {
      throw DatabaseException('Failed to unpin document: $e');
    }
  }

  Future<void> _setPinned(String fileId, String workspaceId, bool pinned) async {
    final db = await dbHelper.database;
    final rows = await db.update(
      DbConstants.workspaceFilesTable,
      {'is_pinned': pinned ? 1 : 0},
      where: 'id = ? AND workspace_id = ?',
      whereArgs: [fileId, workspaceId],
    );
    if (rows == 0) {
      throw DatabaseException('File $fileId not found in workspace $workspaceId');
    }
  }
}
