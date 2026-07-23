import 'dart:io';
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
import 'tables/recent_documents_table.dart';
import 'tables/pinned_documents_table.dart';
import 'tables/scheduler_queue_table.dart';
import 'tables/ai_jobs_table.dart';
import 'tables/knowledge_edges_table.dart';
import 'tables/graph_layouts_table.dart';

/// Singleton class for managing the SQLite (SQLCipher) database connection.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

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
    batch.execute(RecentDocumentsTable.createTableQuery);
    batch.execute(PinnedDocumentsTable.createTableQuery);
    batch.execute(SchedulerQueueTable.createTableQuery);
    batch.execute(AiJobsTable.createTableQuery);
    batch.execute(KnowledgeEdgesTable.createTableQuery);
    batch.execute(GraphLayoutsTable.createTableQuery);
    
    await batch.commit();
  }

  /// Closes the database.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
