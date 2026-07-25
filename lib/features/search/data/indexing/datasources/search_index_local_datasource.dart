import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../../core/database/database_helper.dart';
import '../../../domain/entities/indexing/search_index.dart';
import '../../../domain/entities/indexing/search_index_entry.dart';

/// Local SQLite datasource for persisting and retrieving search indexes.
class SearchIndexLocalDatasource {
  final DatabaseHelper _dbHelper;

  static const String _indexTable = 'search_indexes';
  static const String _entryTable = 'search_index_entries';

  SearchIndexLocalDatasource(this._dbHelper);

  /// Ensures the indexing tables exist.
  Future<void> ensureTables() async {
    final db = await _dbHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_indexTable (
        document_id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        document_type TEXT NOT NULL,
        indexed_at INTEGER NOT NULL,
        word_count INTEGER NOT NULL,
        checksum TEXT NOT NULL,
        parser_version TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_entryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id TEXT NOT NULL,
        normalized_token TEXT NOT NULL,
        original_token TEXT NOT NULL,
        frequency INTEGER NOT NULL,
        positions TEXT NOT NULL,
        field TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES $_indexTable(document_id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_entry_document ON $_entryTable (document_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_entry_token ON $_entryTable (normalized_token)',
    );
  }

  Future<void> saveIndex(SearchIndex index) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Delete existing index for this document
      await txn.delete(_entryTable, where: 'document_id = ?', whereArgs: [index.documentId]);
      await txn.delete(_indexTable, where: 'document_id = ?', whereArgs: [index.documentId]);

      // Insert index header
      await txn.insert(_indexTable, index.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      // Batch insert entries
      final batch = txn.batch();
      for (final entry in index.entries) {
        batch.insert(_entryTable, entry.toMap(index.documentId));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<SearchIndex?> getIndex(String documentId) async {
    final db = await _dbHelper.database;
    final indexMaps = await db.query(_indexTable, where: 'document_id = ?', whereArgs: [documentId]);
    if (indexMaps.isEmpty) return null;

    final entryMaps = await db.query(_entryTable, where: 'document_id = ?', whereArgs: [documentId]);
    final entries = entryMaps.map((m) => SearchIndexEntry.fromMap(m)).toList();

    return SearchIndex.fromMap(indexMaps.first, entries);
  }

  Future<void> deleteIndex(String documentId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(_entryTable, where: 'document_id = ?', whereArgs: [documentId]);
      await txn.delete(_indexTable, where: 'document_id = ?', whereArgs: [documentId]);
    });
  }

  /// Retrieves the checksum and parser version for change detection.
  Future<({String? checksum, String? parserVersion})?> getIndexMeta(String documentId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _indexTable,
      columns: ['checksum', 'parser_version'],
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
    if (result.isEmpty) return null;
    return (
      checksum: result.first['checksum'] as String?,
      parserVersion: result.first['parser_version'] as String?,
    );
  }

  /// Returns all document IDs with indexes for a given workspace.
  Future<List<String>> getIndexedDocumentIds(String workspaceId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _indexTable,
      columns: ['document_id'],
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
    );
    return result.map((m) => m['document_id'] as String).toList();
  }
}
