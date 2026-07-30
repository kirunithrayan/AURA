import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/constants/db_constants.dart';
import '../../../../../core/database/database_helper.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/entities/document_interaction.dart';
import '../../domain/entities/search_interaction.dart';
import '../../domain/repositories/interaction_repository.dart';

class InteractionRepositoryImpl implements InteractionRepository {

  InteractionRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> saveDocumentInteraction(DocumentInteraction interaction) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.documentInteractionsTable,
      {
        'id': interaction.id,
        'document_id': interaction.documentId,
        'view_count': interaction.viewCount,
        'reading_time_ms': interaction.readingTimeMs,
        'last_viewed_at': interaction.lastViewedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<DocumentInteraction?> getDocumentInteraction(String documentId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.documentInteractionsTable,
      where: 'document_id = ?',
      whereArgs: [documentId],
    );

    if (results.isEmpty) return null;
    final row = results.first;
    return DocumentInteraction(
      id: row['id'] as String,
      documentId: row['document_id'] as String,
      viewCount: row['view_count'] as int,
      readingTimeMs: row['reading_time_ms'] as int,
      lastViewedAt: row['last_viewed_at'] as int? ?? 0,
    );
  }

  @override
  Future<List<DocumentInteraction>> getRecentDocumentInteractions(int limit) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.documentInteractionsTable,
      orderBy: 'last_viewed_at DESC',
      limit: limit,
    );
    return results.map((row) => DocumentInteraction(
      id: row['id'] as String,
      documentId: row['document_id'] as String,
      viewCount: row['view_count'] as int,
      readingTimeMs: row['reading_time_ms'] as int,
      lastViewedAt: row['last_viewed_at'] as int? ?? 0,
    )).toList();
  }

  @override
  Future<void> saveSearchInteraction(SearchInteraction interaction) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.searchInteractionsTable,
      {
        'id': interaction.id,
        'query': interaction.query,
        'clicked_document_id': interaction.clickedDocumentId,
        'timestamp': interaction.timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<SearchInteraction>> getRecentSearchInteractions(int limit) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.searchInteractionsTable,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return results.map((row) => SearchInteraction(
      id: row['id'] as String,
      query: row['query'] as String,
      clickedDocumentId: row['clicked_document_id'] as String?,
      timestamp: row['timestamp'] as int,
    )).toList();
  }

  @override
  Future<void> saveConversationSummary(ConversationSummary summary) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.conversationSummariesTable,
      {
        'id': summary.id,
        'workspace_id': summary.workspaceId,
        'summary': summary.summary,
        'topics': summary.topics.join(','),
        'message_count': summary.messageCount,
        'last_updated': summary.lastUpdated,
        'created_at': summary.createdAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ConversationSummary>> getConversationSummaries(String workspaceId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.conversationSummariesTable,
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
      orderBy: 'last_updated DESC',
    );
    return results.map((row) {
      final topicsString = row['topics'] as String;
      return ConversationSummary(
        id: row['id'] as String,
        conversationId: row['id'] as String, // Using id as conversationId for now
        workspaceId: row['workspace_id'] as String,
        summary: row['summary'] as String,
        topics: topicsString.isEmpty ? [] : topicsString.split(','),
        messageCount: row['message_count'] as int,
        lastUpdated: row['last_updated'] as int,
        createdAt: row['created_at'] as int,
      );
    }).toList();
  }

  @override
  Future<int> getConversationCount(String workspaceId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbConstants.conversationSummariesTable} WHERE workspace_id = ?',
      [workspaceId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> clearMemory() async {
    final db = await _dbHelper.database;
    await db.delete(DbConstants.documentInteractionsTable);
    await db.delete(DbConstants.searchInteractionsTable);
    await db.delete(DbConstants.conversationSummariesTable);
  }
}
