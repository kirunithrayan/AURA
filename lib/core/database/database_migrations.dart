import 'package:sqflite_sqlcipher/sqflite.dart';

import '../constants/db_constants.dart';
import 'tables/knowledge_nodes_table.dart';
import 'tables/knowledge_edges_table.dart';
import 'tables/document_interactions_table.dart';
import 'tables/search_interactions_table.dart';
import 'tables/conversation_summaries_table.dart';

/// Handles database migrations between versions.
class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_opened_at INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_viewed_page INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_zoom_level REAL');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN last_scroll_position REAL');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN open_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN page_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN resolution TEXT');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN word_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN paragraph_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN character_count INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN is_favorite INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN is_pinned INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.workspaceFilesTable} ADD COLUMN is_archived INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_last_opened ON ${DbConstants.workspaceFilesTable} (last_opened_at)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_favorite ON ${DbConstants.workspaceFilesTable} (is_favorite)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_pinned ON ${DbConstants.workspaceFilesTable} (is_pinned)');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE ${DbConstants.searchHistoryTable} ADD COLUMN last_used INTEGER');
      await db.execute('ALTER TABLE ${DbConstants.searchHistoryTable} ADD COLUMN hit_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${DbConstants.searchHistoryTable} ADD COLUMN is_pinned INTEGER DEFAULT 0');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE ${DbConstants.embeddingsTable} ADD COLUMN chunk_id TEXT');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_embeddings_chunk_id ON ${DbConstants.embeddingsTable} (chunk_id)');
    }
    if (oldVersion < 8) {
      await db.execute('DROP TABLE IF EXISTS ${DbConstants.knowledgeEdgesTable}');
      await db.execute(KnowledgeNodesTable.createTableQuery);
      await db.execute(KnowledgeEdgesTable.createTableQuery);
    }
    if (oldVersion < 9) {
      await db.execute(DocumentInteractionsTable.createTableQuery);
      await db.execute(SearchInteractionsTable.createTableQuery);
      await db.execute(ConversationSummariesTable.createTableQuery);
    }
    if (oldVersion < 10) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_workspace_id ON ${DbConstants.workspaceFilesTable} (workspace_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_embeddings_file_chunk ON ${DbConstants.embeddingsTable} (file_id, chunk_index)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_knowledge_nodes_workspace ON ${DbConstants.knowledgeNodesTable} (workspace_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_knowledge_edges_source_target ON ${DbConstants.knowledgeEdgesTable} (source_id, target_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_document_interactions_doc ON ${DbConstants.documentInteractionsTable} (document_id)');
    }
  }
}
