import '../models/embedding_result.dart';

/// Abstract interface for the Embedding Engine.
abstract class EmbeddingEngine {
  /// Initializes the underlying model/runtime.
  Future<void> initialize();

  /// Generates an embedding for a single string of text.
  Future<EmbeddingResult> generateEmbedding(String text);

  /// Generates embeddings for a batch of text strings.
  Future<List<EmbeddingResult>> generateBatchEmbeddings(List<String> texts);

  /// Returns the current active model version string.
  String getModelVersion();

  /// Returns the dimension size of the output vectors.
  int getDimensions();

  /// Disposes of underlying resources.
  Future<void> dispose();
}
