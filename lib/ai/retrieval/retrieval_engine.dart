import '../models/retrieval_result.dart';
import '../models/document_chunk.dart';

/// Abstract interface for the semantic retrieval engine.
abstract class RetrievalEngine {
  /// Performs a semantic search across all embedded chunks in the database.
  Future<List<RetrievalResult>> semanticSearch(
    String query, {
    int topK = 10,
    String? workspaceId,
  });

  /// Finds documents related to the given file ID based on chunk embeddings.
  Future<List<RetrievalResult>> findRelatedDocuments(
    String fileId, {
    int topK = 5,
  });

  /// Retrieves all chunks for a specific document.
  Future<List<DocumentChunk>> getDocumentChunks(String fileId);
}
