// Real-SQLite integration coverage for the multi-table transaction inside
// WorkspaceLocalDataSourceImpl.removeFile() — the single-document sibling of
// deleteWorkspace().
//
// The companion document_deletion_test.dart exercises the REPOSITORY
// orchestration against a fake datasource, so the raw SQL — the highest-risk
// code, where a wrong table/column name or a bad scoping clause would live —
// gets its coverage here, against the ACTUAL production datasource running on a
// real in-memory SQLite database (sqflite_common_ffi), built from the SAME
// table DDL the app ships. No fake datasource, no mock SQL.
//
// PRAGMA foreign_keys is deliberately left OFF, exactly as production runs it
// (DatabaseHelper never enables it). The declared ON DELETE CASCADE clauses are
// inert here too, so these tests prove the datasource's EXPLICIT per-table
// deletes are what clean up. Crucially, removeFile is FILE-scoped: it must
// clean the target file's rows without touching its siblings, and must delete
// ONLY the document's own knowledge node (id == file id) while leaving shared
// concept nodes intact.

import 'package:flutter_test/flutter_test.dart';
// Hide sqflite's own DatabaseException so the aura DatabaseException (what the
// production datasource actually throws) is the one this test asserts on.
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

import 'package:aura/core/constants/db_constants.dart';
import 'package:aura/core/database/database_helper.dart';
import 'package:aura/features/workspace/data/datasources/workspace_local_datasource.dart';

// Table DDL — the exact classes DatabaseHelper._onCreate wires in, imported so
// the test schema can never drift from the shipped schema.
import 'package:aura/core/database/tables/workspaces_table.dart';
import 'package:aura/core/database/tables/workspace_files_table.dart';
import 'package:aura/core/database/tables/embeddings_table.dart';
import 'package:aura/core/database/tables/tags_table.dart';
import 'package:aura/core/database/tables/search_history_table.dart';
import 'package:aura/core/database/tables/scheduler_queue_table.dart';
import 'package:aura/core/database/tables/ai_jobs_table.dart';
import 'package:aura/core/database/tables/knowledge_nodes_table.dart';
import 'package:aura/core/database/tables/knowledge_edges_table.dart';
import 'package:aura/core/database/tables/graph_layouts_table.dart';
import 'package:aura/core/database/tables/document_interactions_table.dart';
import 'package:aura/core/database/tables/search_interactions_table.dart';
import 'package:aura/core/database/tables/conversation_summaries_table.dart';
import 'package:aura/core/database/tables/search_indexes_table.dart';
import 'package:aura/core/database/tables/search_index_entries_table.dart';

/// Minimal stand-in for DatabaseHelper that hands the datasource a
/// pre-opened database. DatabaseHelper's instance interface is just the
/// `database` getter and `close()`; everything else on it is static or
/// private, so this is the whole contract the datasource depends on.
class _FfiDatabaseHelper implements DatabaseHelper {
  _FfiDatabaseHelper(this._db);
  final Database _db;

  @override
  Future<Database> get database async => _db;

  @override
  Future<void> close() async => _db.close();
}

/// Builds the real schema on [db] in the same order as DatabaseHelper._onCreate.
Future<void> _createSchema(Database db) async {
  final batch = db.batch();
  batch.execute(WorkspacesTable.createTableQuery);
  batch.execute(WorkspaceFilesTable.createTableQuery);
  batch.execute(EmbeddingsTable.createTableQuery);
  batch.execute(TagsTable.createTableQuery);
  batch.execute(SearchHistoryTable.createTableQuery);
  batch.execute(SchedulerQueueTable.createTableQuery);
  batch.execute(AiJobsTable.createTableQuery);
  batch.execute(KnowledgeNodesTable.createTableQuery);
  batch.execute(KnowledgeEdgesTable.createTableQuery);
  batch.execute(GraphLayoutsTable.createTableQuery);
  batch.execute(DocumentInteractionsTable.createTableQuery);
  batch.execute(SearchInteractionsTable.createTableQuery);
  batch.execute(ConversationSummariesTable.createTableQuery);
  batch.execute(SearchIndexesTable.createTableQuery);
  batch.execute(SearchIndexEntriesTable.createTableQuery);
  await batch.commit(noResult: true);
}

Future<int> _count(Database db, String table, {String? where, List<Object?>? args}) async {
  final rows = await db.query(table, where: where, whereArgs: args);
  return rows.length;
}

void main() {
  setUpAll(sqfliteFfiInit);

  late Database db;
  late WorkspaceLocalDataSourceImpl dataSource;

  setUp(() async {
    // A fresh, isolated in-memory database per test.
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await _createSchema(db);
    dataSource = WorkspaceLocalDataSourceImpl(_FfiDatabaseHelper(db));
  });

  tearDown(() async {
    await db.close();
  });

  // ---------------------------------------------------------------------------
  // Seed helpers. Each inserts one row into a workspace- or file-scoped table.
  // ---------------------------------------------------------------------------
  Future<void> insertWorkspace(String id, {int fileCount = 0, int totalSize = 0}) =>
      db.insert(DbConstants.workspacesTable,
          {'id': id, 'name': 'Workspace $id', 'file_count': fileCount, 'total_size': totalSize});

  Future<void> insertFile(String id, String workspaceId, {int? size}) => db.insert(
        DbConstants.workspaceFilesTable,
        {'id': id, 'workspace_id': workspaceId, 'file_name': '$id.txt', 'file_path': '/tmp/$id.txt', 'size': size},
      );

  // A document node's id equals the file id (1:1 owned by the file).
  Future<void> insertDocNode(String fileId, String workspaceId) => db.insert(
        DbConstants.knowledgeNodesTable,
        {'id': fileId, 'label': fileId, 'type': 'document', 'workspace_id': workspaceId, 'document_id': fileId, 'created_at': 0},
      );

  // A concept node is shared across documents; its id looks like 'concept:...'.
  Future<void> insertConceptNode(String id, String workspaceId) => db.insert(
        DbConstants.knowledgeNodesTable,
        {'id': id, 'label': id, 'type': 'concept', 'workspace_id': workspaceId, 'created_at': 0},
      );

  Future<void> insertEdge(String id, String sourceId, String targetId) => db.insert(
        DbConstants.knowledgeEdgesTable,
        {'id': id, 'source_id': sourceId, 'target_id': targetId, 'relationship_type': 'rel', 'weight': 1.0, 'created_at': 0},
      );

  Future<void> insertEmbedding(String id, String fileId) =>
      db.insert(DbConstants.embeddingsTable, {'id': id, 'file_id': fileId, 'chunk_index': 0});

  Future<void> insertInteraction(String id, String documentId) => db.insert(
        DbConstants.documentInteractionsTable,
        {'id': id, 'document_id': documentId, 'view_count': 1},
      );

  Future<void> insertAiJob(String id, String fileId) =>
      db.insert(DbConstants.aiJobsTable, {'id': id, 'file_id': fileId, 'job_type': 'summary', 'status': 'done'});

  Future<void> insertSchedulerJob(String id, String fileId) =>
      db.insert(DbConstants.schedulerQueueTable, {'id': id, 'file_id': fileId, 'job_type': 'embedding', 'status': 'pending'});

  Future<void> insertGraphLayout(String id, String workspaceId, String fileId) => db.insert(
        DbConstants.graphLayoutsTable,
        {'id': id, 'workspace_id': workspaceId, 'file_id': fileId, 'x_position': 1.0, 'y_position': 2.0},
      );

  Future<void> insertSearchInteraction(String id, String? clickedDocumentId) => db.insert(
        DbConstants.searchInteractionsTable,
        {'id': id, 'query': 'q', 'clicked_document_id': clickedDocumentId, 'timestamp': 0},
      );

  Future<void> insertConversationSummary(String id, String workspaceId) => db.insert(
        DbConstants.conversationSummariesTable,
        {'id': id, 'workspace_id': workspaceId, 'summary': 's', 'topics': 't', 'message_count': 1, 'last_updated': 0, 'created_at': 0},
      );

  Future<void> insertSearchHistory(String id, String workspaceId) => db.insert(
        DbConstants.searchHistoryTable,
        {'id': id, 'query': 'q', 'workspace_id': workspaceId},
      );

  /// Seeds one file plus one row in every file-scoped table it touches, its
  /// document knowledge node, and an edge from that document node to a shared
  /// concept node. Returns nothing; caller seeds the workspace/concept nodes.
  Future<void> seedFileWithRelations(String ws, String file, String conceptId) async {
    await insertFile(file, ws, size: 100);
    await insertEmbedding('emb-$file', file);
    await insertInteraction('int-$file', file);
    await insertAiJob('job-$file', file);
    await insertSchedulerJob('sch-$file', file);
    await insertGraphLayout('gl-$file', ws, file);
    await insertDocNode(file, ws);
    await insertEdge('edge-$file', file, conceptId); // document -> concept
    await insertSearchInteraction('si-$file', file);
  }

  group('removeFile real-SQLite integration', () {
    test('verifies it is running against real SQLite with FK enforcement OFF', () async {
      final v = await db.rawQuery('SELECT sqlite_version() AS v');
      expect(v.first['v'], isA<String>());
      expect((v.first['v'] as String).isNotEmpty, isTrue);
      final fk = await db.rawQuery('PRAGMA foreign_keys');
      expect(fk.first.values.first, 0, reason: 'production never enables FK enforcement');
    });

    test('deletes the target workspace_files row (and leaves siblings)', () async {
      await insertWorkspace('ws-A', fileCount: 2, totalSize: 200);
      await insertFile('file-A', 'ws-A', size: 100);
      await insertFile('file-B', 'ws-A', size: 100);

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.workspaceFilesTable, where: 'id = ?', args: ['file-A']), 0);
      expect(await _count(db, DbConstants.workspaceFilesTable, where: 'id = ?', args: ['file-B']), 1);
    });

    test('deletes the file rows in embeddings, document_interactions, ai_jobs, scheduler_queue, graph_layouts', () async {
      await insertWorkspace('ws-A', fileCount: 1, totalSize: 100);
      await insertConceptNode('concept:ws-A:math', 'ws-A');
      await seedFileWithRelations('ws-A', 'file-A', 'concept:ws-A:math');

      await dataSource.removeFile('file-A');

      for (final (table, col) in const [
        (DbConstants.embeddingsTable, 'file_id'),
        (DbConstants.documentInteractionsTable, 'document_id'),
        (DbConstants.aiJobsTable, 'file_id'),
        (DbConstants.schedulerQueueTable, 'file_id'),
        (DbConstants.graphLayoutsTable, 'file_id'),
      ]) {
        expect(await _count(db, table, where: '$col = ?', args: ['file-A']), 0,
            reason: '$table still has a row for the deleted file');
      }
    });

    test('nullifies search_interactions.clicked_document_id for the deleted file, without deleting the row', () async {
      await insertWorkspace('ws-A', fileCount: 1, totalSize: 100);
      await insertFile('file-A', 'ws-A', size: 100);
      await insertSearchInteraction('si-A', 'file-A'); // points at the deleted file
      await insertSearchInteraction('si-null', null); // already null

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.searchInteractionsTable), 2, reason: 'SET NULL, not DELETE');
      final siA = (await db.query(DbConstants.searchInteractionsTable, where: 'id = ?', whereArgs: ['si-A'])).single;
      expect(siA['clicked_document_id'], isNull, reason: 'reference to the deleted file must be nulled');
    });

    test('deletes the document knowledge_node (id == fileId) AND its edges', () async {
      await insertWorkspace('ws-A', fileCount: 1, totalSize: 100);
      await insertConceptNode('concept:ws-A:math', 'ws-A');
      await insertDocNode('file-A', 'ws-A');
      await insertFile('file-A', 'ws-A', size: 100);
      await insertEdge('edge-A', 'file-A', 'concept:ws-A:math'); // document -> concept
      await insertEdge('edge-A2', 'concept:ws-A:math', 'file-A'); // concept -> document

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.knowledgeNodesTable, where: 'id = ?', args: ['file-A']), 0,
          reason: 'the document node (id == fileId) must be deleted');
      expect(await _count(db, DbConstants.knowledgeEdgesTable), 0,
          reason: 'every edge touching the document node must be deleted');
    });

    test('does NOT delete shared concept nodes, nor another file\'s document node', () async {
      await insertWorkspace('ws-A', fileCount: 2, totalSize: 200);
      await insertConceptNode('concept:ws-A:math', 'ws-A');
      await insertDocNode('file-A', 'ws-A');
      await insertDocNode('file-B', 'ws-A');
      await insertFile('file-A', 'ws-A', size: 100);
      await insertFile('file-B', 'ws-A', size: 100);
      // Both documents connect to the SAME shared concept node.
      await insertEdge('edge-A', 'file-A', 'concept:ws-A:math');
      await insertEdge('edge-B', 'file-B', 'concept:ws-A:math');

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.knowledgeNodesTable, where: 'id = ?', args: ['concept:ws-A:math']), 1,
          reason: 'the shared concept node must survive');
      expect(await _count(db, DbConstants.knowledgeNodesTable, where: 'id = ?', args: ['file-B']), 1,
          reason: "another file's document node must survive");
      expect(await _count(db, DbConstants.knowledgeEdgesTable, where: 'id = ?', args: ['edge-B']), 1,
          reason: "file-B's edge to the shared concept must survive");
    });

    test('decrements the parent workspace file_count and total_size', () async {
      await insertWorkspace('ws-A', fileCount: 3, totalSize: 500);
      await insertFile('file-A', 'ws-A', size: 100);

      await dataSource.removeFile('file-A');

      final ws = (await db.query(DbConstants.workspacesTable, where: 'id = ?', whereArgs: ['ws-A'])).single;
      expect(ws['file_count'], 2, reason: 'file_count must drop by one');
      expect(ws['total_size'], 400, reason: 'total_size must drop by the deleted file size');
    });

    test('CROSS-DOCUMENT ISOLATION: deleting file A leaves file B and all of B\'s rows intact', () async {
      await insertWorkspace('ws-A', fileCount: 2, totalSize: 200);
      await insertConceptNode('concept:ws-A:math', 'ws-A');
      await seedFileWithRelations('ws-A', 'file-A', 'concept:ws-A:math');
      await seedFileWithRelations('ws-A', 'file-B', 'concept:ws-A:math');

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.workspaceFilesTable, where: 'id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.embeddingsTable, where: 'file_id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.documentInteractionsTable, where: 'document_id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.aiJobsTable, where: 'file_id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.schedulerQueueTable, where: 'file_id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.graphLayoutsTable, where: 'file_id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.knowledgeNodesTable, where: 'id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.knowledgeEdgesTable, where: 'id = ?', args: ['edge-file-B']), 1);
      final siB = (await db.query(DbConstants.searchInteractionsTable, where: 'id = ?', whereArgs: ['si-file-B'])).single;
      expect(siB['clicked_document_id'], 'file-B', reason: "file-B's search interaction must be untouched");
    });

    test('CROSS-WORKSPACE ISOLATION: deleting a file in ws-A leaves ws-B and its files untouched', () async {
      await insertWorkspace('ws-A', fileCount: 1, totalSize: 100);
      await insertWorkspace('ws-B', fileCount: 1, totalSize: 100);
      await insertConceptNode('concept:ws-A:math', 'ws-A');
      await insertConceptNode('concept:ws-B:math', 'ws-B');
      await seedFileWithRelations('ws-A', 'file-A', 'concept:ws-A:math');
      await seedFileWithRelations('ws-B', 'file-B', 'concept:ws-B:math');

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.workspacesTable, where: 'id = ?', args: ['ws-B']), 1);
      expect(await _count(db, DbConstants.workspaceFilesTable, where: 'id = ?', args: ['file-B']), 1);
      expect(await _count(db, DbConstants.knowledgeNodesTable, where: 'workspace_id = ?', args: ['ws-B']), 2,
          reason: "ws-B's concept and document nodes must survive");
      expect(await _count(db, DbConstants.embeddingsTable, where: 'file_id = ?', args: ['file-B']), 1);
      final wsB = (await db.query(DbConstants.workspacesTable, where: 'id = ?', whereArgs: ['ws-B'])).single;
      expect(wsB['file_count'], 1, reason: "ws-B's counters must not move");
      expect(wsB['total_size'], 100);
    });

    test('does NOT touch conversation_summaries or search_history (workspace-scoped, not file-scoped)', () async {
      await insertWorkspace('ws-A', fileCount: 1, totalSize: 100);
      await insertFile('file-A', 'ws-A', size: 100);
      await insertConversationSummary('cs-A', 'ws-A');
      await insertSearchHistory('sh-A', 'ws-A');

      await dataSource.removeFile('file-A');

      expect(await _count(db, DbConstants.conversationSummariesTable, where: 'workspace_id = ?', args: ['ws-A']), 1,
          reason: 'conversation_summaries is workspace-scoped and must survive a single-file delete');
      expect(await _count(db, DbConstants.searchHistoryTable, where: 'workspace_id = ?', args: ['ws-A']), 1,
          reason: 'search_history is workspace-scoped and must survive a single-file delete');
    });
  });
}
