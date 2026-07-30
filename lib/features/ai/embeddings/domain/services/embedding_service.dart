/// Abstract interface for semantic embedding generation.
abstract class EmbeddingService {
  /// Initializes the embedding service (e.g. loads models).
  Future<void> initialize();

  /// Generates a vector embedding for the given text.
  Future<List<double>> generateEmbedding(String text);

  /// Generates embeddings for a list of texts in batch.
  Future<List<List<double>>> generateEmbeddingsBatch(List<String> texts);

  /// Disposes of any resources held by the service.
  Future<void> dispose();
}
