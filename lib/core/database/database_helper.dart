import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_logger.dart';
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
  Future<Database>? _opening;

  // resetOnError: if the Keystore-wrapped store can no longer be decrypted
  // (observed on a real device as BadPaddingException: BAD_DECRYPT — the exact
  // trigger is not proven; an auto-backup restore or a Keystore rotation are
  // likely candidates), the plugin resets the corrupt store and returns null
  // instead of throwing, so key retrieval can self-heal.
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  /// Gets the initialized database instance.
  ///
  /// Initialization is serialized through a single future so concurrent first
  /// callers cannot each run [_initDatabase] and mint competing keys.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _opening ??= _initDatabase();
    try {
      _database = await _opening!;
      return _database!;
    } finally {
      _opening = null;
    }
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DbConstants.databaseName);

    final (:String key, :bool freshlyGenerated) = await _getDatabasePassword();

    Future<Database> open() => openDatabase(
          path,
          version: DbConstants.databaseVersion,
          password: key,
          onCreate: _onCreate,
          onUpgrade: DatabaseMigrations.onUpgrade,
        );

    try {
      return await open();
    } catch (e) {
      // Recreate the database ONLY when both are true:
      //   1. we just minted a fresh key because the previous one was
      //      unrecoverable (so any existing file is encrypted with a now-lost
      //      key and cannot be read with any available key), and
      //   2. the failure looks like an open/decrypt failure.
      // A healthy (existing) key that fails to open is a real database problem
      // (disk, corruption, migration, a bug) and must NOT be deleted — it is
      // surfaced instead. This makes deletion recovery from an
      // already-unrecoverable state, never destruction of a healthy database.
      if (!(freshlyGenerated && _isOpenDecryptFailure(e))) rethrow;
      AppLogger.error(
        'Database is encrypted with a lost key; recreating it',
        e,
        null,
        LogCategory.database,
      );
      await deleteDatabase(path);
      return await open();
    }
  }

  Future<({String key, bool freshlyGenerated})> _getDatabasePassword() async {
    if (kDebugMode) return (key: 'debug_password', freshlyGenerated: false);
    return resolveDatabaseKey(
      read: () => _secureStorage.read(key: DbConstants.encryptionKeyAlias),
      write: (String value) =>
          _secureStorage.write(key: DbConstants.encryptionKeyAlias, value: value),
      deleteKey: () => _secureStorage.delete(key: DbConstants.encryptionKeyAlias),
      generate: () => const Uuid().v4(),
      isUnrecoverable: _isSecureStoreDecryptError,
    );
  }

  /// Resolves the database encryption key, tolerating a genuinely
  /// undecryptable secure-storage entry while surfacing every other failure.
  ///
  /// Historically this read the key directly; on a real device
  /// `FlutterSecureStorage.read` threw `BadPaddingException: BAD_DECRYPT` when
  /// the Keystore-wrapped value could no longer be decrypted. That exception
  /// aborted every database operation and surfaced only as "Failed to create
  /// workspace".
  ///
  /// Recovery rules:
  ///  - read returns a value        -> use it (`freshlyGenerated: false`).
  ///  - read returns null           -> mint + persist a key
  ///                                   (`freshlyGenerated: true`).
  ///  - read throws & [isUnrecoverable] -> drop the corrupt entry, then mint +
  ///                                   persist a key (`freshlyGenerated: true`).
  ///  - read throws otherwise       -> rethrow (an unexpected secure-storage /
  ///                                   platform / I/O failure must never be
  ///                                   mistaken for "no key").
  ///
  /// `freshlyGenerated` tells the caller whether the returned key is new, which
  /// is the only condition under which recreating an unreadable database file
  /// is safe. Extracted and [visibleForTesting] so every branch is unit-tested
  /// without a real platform Keystore.
  @visibleForTesting
  static Future<({String key, bool freshlyGenerated})> resolveDatabaseKey({
    required Future<String?> Function() read,
    required Future<void> Function(String value) write,
    required Future<void> Function() deleteKey,
    required String Function() generate,
    required bool Function(Object error) isUnrecoverable,
  }) async {
    try {
      final String? existing = await read();
      if (existing != null) return (key: existing, freshlyGenerated: false);
      // No key stored: a fresh install, or the store was reset after an
      // unrecoverable decrypt failure (AndroidOptions.resetOnError). Mint below.
    } catch (e) {
      if (!isUnrecoverable(e)) rethrow;
      AppLogger.error(
        'Secure storage key unrecoverable; regenerating',
        e,
        null,
        LogCategory.database,
      );
      try {
        await deleteKey();
      } catch (_) {
        // Best effort: if the corrupt entry cannot be deleted, overwriting it
        // below with a fresh value still recovers a usable state.
      }
    }
    final String key = generate();
    await write(key);
    return (key: key, freshlyGenerated: true);
  }

  /// True only for a secure-storage value that cannot be decrypted at all.
  static bool _isSecureStoreDecryptError(Object e) {
    final String msg = e.toString().toLowerCase();
    return msg.contains('bad_decrypt') || msg.contains('badpadding');
  }

  /// True for an sqflite open failure consistent with a wrong/lost key.
  ///
  /// sqflite_sqlcipher surfaces a wrong-key open as a generic
  /// `DatabaseException(open_failed <path>)`; the underlying sqlcipher detail
  /// (hmac / "file is not a database") is not always included. This is only
  /// ever consulted when a fresh key was just generated, so it never widens
  /// deletion to a healthy database.
  static bool _isOpenDecryptFailure(Object e) {
    final String msg = e.toString().toLowerCase();
    return msg.contains('open_failed') ||
        msg.contains('file is not a database') ||
        msg.contains('not a database') ||
        msg.contains('bad_decrypt') ||
        msg.contains('badpadding') ||
        msg.contains('hmac');
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
