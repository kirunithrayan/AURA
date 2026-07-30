import '../entities/embedding_vector.dart';

/// Abstract interface for generating vector embeddings from text.
abstract class AbstractEmbeddingEngine {
  /// Generates an embedding vector for a single text input.
  Future<EmbeddingVector> generateEmbedding(String text);

  /// Generates embedding vectors for a batch of text inputs.
  Future<List<EmbeddingVector>> generateBatchEmbeddings(List<String> texts);
}
