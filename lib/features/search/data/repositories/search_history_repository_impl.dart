import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_history_repository.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final DatabaseHelper _dbHelper;

  SearchHistoryRepositoryImpl(this._dbHelper);

  @override
  Future<void> saveEntry(SearchHistoryEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.searchHistoryTable,
      _toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateEntry(SearchHistoryEntry entry) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.searchHistoryTable,
      _toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<List<SearchHistoryEntry>> getRecentEntries({int limit = 50}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.searchHistoryTable,
      orderBy: 'last_used DESC, created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<void> deleteEntry(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DbConstants.searchHistoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete(DbConstants.searchHistoryTable);
  }

  Map<String, dynamic> _toMap(SearchHistoryEntry entry) {
    return {
      'id': entry.id,
      'query': entry.query,
      'search_type': 'hybrid', // Setting a default type
      'result_count': entry.resultCount,
      'workspace_id': entry.workspaceId,
      'created_at': entry.searchedAt.millisecondsSinceEpoch,
      'last_used': entry.lastUsed.millisecondsSinceEpoch,
      'hit_count': entry.hitCount,
      'is_pinned': entry.pinned ? 1 : 0,
    };
  }

  SearchHistoryEntry _fromMap(Map<String, dynamic> map) {
    return SearchHistoryEntry(
      id: map['id'],
      query: map['query'],
      searchedAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastUsed: map['last_used'] != null ? DateTime.fromMillisecondsSinceEpoch(map['last_used']) : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      hitCount: map['hit_count'] ?? 1,
      pinned: (map['is_pinned'] ?? 0) == 1,
      workspaceId: map['workspace_id'],
      resultCount: map['result_count'] ?? 0,
    );
  }
}
