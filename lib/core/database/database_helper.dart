import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../constants/db_constants.dart';
import 'database_migrations.dart';
import 'tables/workspaces_table.dart';
import 'tables/workspace_files_table.dart';
import 'tables/embeddings_table.dart';
import 'tables/tags_table.dart';
import 'tables/search_history_table.dart';
import 'tables/scheduler_queue_table.dart';
import 'tables/ai_jobs_table.dart';
import 'tables/knowledge_nodes_table.dart';
import 'tables/knowledge_edges_table.dart';
import 'tables/graph_layouts_table.dart';
import 'tables/document_interactions_table.dart';
import 'tables/search_interactions_table.dart';
import 'tables/conversation_summaries_table.dart';
import 'tables/search_indexes_table.dart';
import 'tables/search_index_entries_table.dart';

/// Singleton class for managing the SQLite (SQLCipher) database connection.
class DatabaseHelper {
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  Database? _database;
  final _secureStorage = const FlutterSecureStorage();

  /// Gets the initialized database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DbConstants.databaseName);
    
    // In a real production app, you would retrieve/generate the key from SecureStorage.
    // For this build, we use a simple stub to ensure it compiles without complex async secure storage flow.
    final password = await _getDatabasePassword();

    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      password: password,
      onCreate: _onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }

  Future<String> _getDatabasePassword() async {
    if (kDebugMode) return 'debug_password';
    
    String? key = await _secureStorage.read(key: DbConstants.encryptionKeyAlias);
    if (key == null) {
      key = const Uuid().v4();
      await _secureStorage.write(key: DbConstants.encryptionKeyAlias, value: key);
    }
    return key;
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // Performance indexes
    batch.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_last_opened ON ${DbConstants.workspaceFilesTable} (last_opened_at)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_favorite ON ${DbConstants.workspaceFilesTable} (is_favorite)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_pinned ON ${DbConstants.workspaceFilesTable} (is_pinned)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_workspace_files_workspace_id ON ${DbConstants.workspaceFilesTable} (workspace_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_embeddings_file_chunk ON ${DbConstants.embeddingsTable} (file_id, chunk_index)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_knowledge_nodes_workspace ON ${DbConstants.knowledgeNodesTable} (workspace_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_knowledge_edges_source_target ON ${DbConstants.knowledgeEdgesTable} (source_id, target_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_document_interactions_doc ON ${DbConstants.documentInteractionsTable} (document_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_search_index_entries_document ON ${DbConstants.searchIndexEntriesTable} (document_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_search_index_entries_token ON ${DbConstants.searchIndexEntriesTable} (normalized_token)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_search_indexes_workspace ON ${DbConstants.searchIndexesTable} (workspace_id)');

    await batch.commit();
  }

  /// Closes the database.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
