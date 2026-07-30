import '../entities/indexed_document_chunk.dart';

/// Repository for persisting and retrieving document embeddings.
abstract class EmbeddingRepository {
  /// Saves a single document embedding.
  Future<void> saveEmbedding(IndexedDocumentChunk embedding);

  /// Saves a batch of document embeddings.
  Future<void> saveEmbeddings(List<IndexedDocumentChunk> embeddings);

  /// Retrieves all embeddings for a specific document.
  Future<List<IndexedDocumentChunk>> getDocumentEmbeddings(String documentId);

  /// Deletes all embeddings for a specific document.
  Future<void> deleteDocumentEmbeddings(String documentId);
}
