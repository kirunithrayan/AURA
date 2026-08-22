import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
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
    } catch (e, s) {
      AppLogger.error('createWorkspace failed', e, s, LogCategory.workspace);
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

  // File-scoped sibling of [deleteWorkspace]: removes a SINGLE file and only
  // the rows that file strictly owns, in one transaction. Every delete is keyed
  // on the file id (embeddings/ai_jobs/scheduler_queue/graph_layouts by
  // file_id, document_interactions by document_id), never on workspace_id, so a
  // file's removal can never touch its siblings. As with deleteWorkspace,
  // `PRAGMA foreign_keys` is off, so these explicit deletes are what actually
  // clean up; declared cascades never fire.
  //
  // Knowledge graph: only the document's OWN node and its edges are removed. A
  // document node's id equals the file id (1:1 owned by this file), so it is
  // deleted by `id = fileId`. Concept nodes (ids like `concept:...`) are shared
  // across documents and MUST survive — this never deletes knowledge_nodes by
  // document_id, which would corrupt those shared concepts. conversation_summaries
  // and search_history are workspace-scoped, not file-scoped, and are left intact.
  // search_indexes has no FK and is cleaned at the repository layer via
  // SearchIndexService, exactly as deleteWorkspace does.
  @override
  Future<void> removeFile(String id) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        final fileRows = await txn.query(
          DbConstants.workspaceFilesTable,
          where: 'id = ?',
          whereArgs: [id],
        );
        // If the row is already gone, the deletes below simply no-op; only the
        // counter update is skipped (there is no parent workspace to adjust).
        // Read only the two columns the counter update needs rather than parsing
        // a full model: removeFile must not fail because some unrelated column
        // (e.g. a null timestamp, which the schema permits) can't be cast.
        final Map<String, Object?>? fileRow =
            fileRows.isEmpty ? null : fileRows.first;
        final String? fileWorkspaceId = fileRow?['workspace_id'] as String?;
        final int fileSize = (fileRow?['size'] as int?) ?? 0;

        await txn.delete(DbConstants.embeddingsTable,
            where: 'file_id = ?', whereArgs: [id]);
        await txn.delete(DbConstants.documentInteractionsTable,
            where: 'document_id = ?', whereArgs: [id]);
        await txn.delete(DbConstants.aiJobsTable,
            where: 'file_id = ?', whereArgs: [id]);
        await txn.delete(DbConstants.schedulerQueueTable,
            where: 'file_id = ?', whereArgs: [id]);
        // graph_layouts is deleted file-scoped ONLY; deleting by workspace_id
        // here would wipe layouts belonging to the file's siblings.
        await txn.delete(DbConstants.graphLayoutsTable,
            where: 'file_id = ?', whereArgs: [id]);

        // Declared ON DELETE SET NULL: nullify rather than delete, keeping the
        // interaction record while dropping the dangling reference.
        await txn.update(
          DbConstants.searchInteractionsTable,
          {'clicked_document_id': null},
          where: 'clicked_document_id = ?',
          whereArgs: [id],
        );

        // knowledge_edges references node ids; the document node's id == file id,
        // so its edges are the ones with this id as an endpoint. Delete edges
        // before the node. Then delete ONLY the strictly-owned document node
        // (id == file id); shared concept nodes are never matched by this.
        await txn.delete(
          DbConstants.knowledgeEdgesTable,
          where: 'source_id = ? OR target_id = ?',
          whereArgs: [id, id],
        );
        await txn.delete(DbConstants.knowledgeNodesTable,
            where: 'id = ?', whereArgs: [id]);

        if (fileWorkspaceId != null) {
          await txn.rawUpdate(
            'UPDATE ${DbConstants.workspacesTable} '
            'SET file_count = file_count - 1, total_size = total_size - ? '
            'WHERE id = ?',
            [fileSize, fileWorkspaceId],
          );
        }

        await txn.delete(DbConstants.workspaceFilesTable,
            where: 'id = ?', whereArgs: [id]);
      });
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
