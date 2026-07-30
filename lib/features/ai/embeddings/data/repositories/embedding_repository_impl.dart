import 'dart:typed_data';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../../core/database/database_helper.dart';
import '../../../../../core/constants/db_constants.dart';
import '../../domain/entities/indexed_document_chunk.dart';
import '../../domain/repositories/embedding_repository.dart';

/// Implementation of [EmbeddingRepository] using SQLite.
class EmbeddingRepositoryImpl implements EmbeddingRepository {

  const EmbeddingRepositoryImpl(this._databaseHelper);
  final DatabaseHelper _databaseHelper;

  @override
  Future<void> saveEmbedding(IndexedDocumentChunk embedding) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DbConstants.embeddingsTable,
      _toMap(embedding),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveEmbeddings(List<IndexedDocumentChunk> embeddings) async {
    if (embeddings.isEmpty) return;

    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (final embedding in embeddings) {
      batch.insert(
        DbConstants.embeddingsTable,
        _toMap(embedding),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<IndexedDocumentChunk>> getDocumentEmbeddings(String documentId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DbConstants.embeddingsTable,
      where: 'file_id = ?',
      whereArgs: [documentId],
    );

    return maps.map(_fromMap).toList();
  }

  @override
  Future<void> deleteDocumentEmbeddings(String documentId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DbConstants.embeddingsTable,
      where: 'file_id = ?',
      whereArgs: [documentId],
    );
  }

  Map<String, dynamic> _toMap(IndexedDocumentChunk embedding) {
    // Convert List<double> to a byte array (BLOB) for efficient storage
    final Float32List float32List = Float32List.fromList(embedding.embedding);
    final Uint8List byteList = float32List.buffer.asUint8List();

    return {
      'id': embedding.chunkId, // Map chunkId to id in DB if they are the same
      'file_id': embedding.documentId,
      'chunk_id': embedding.chunkId,
      'chunk_index': embedding.chunkIndex,
      'text_snippet': embedding.textSnippet,
      'embedding': byteList,
      'created_at': embedding.createdAt,
    };
  }

  IndexedDocumentChunk _fromMap(Map<String, dynamic> map) {
    final Uint8List byteList = map['embedding'] as Uint8List;
    final Float32List float32List = Float32List.view(byteList.buffer);
    final List<double> vector = float32List.toList();

    return IndexedDocumentChunk(
      chunkId: map['chunk_id'] as String? ?? map['id'] as String,
      documentId: map['file_id'] as String,
      chunkIndex: map['chunk_index'] as int? ?? 0,
      textSnippet: map['text_snippet'] as String? ?? '',
      embedding: vector,
      createdAt: map['created_at'] as int,
    );
  }
}
