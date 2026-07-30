import '../../domain/engines/abstract_embedding_engine.dart';
import '../../domain/entities/embedding_vector.dart';

/// Stub implementation of [AbstractEmbeddingEngine] for DI registration.
/// Throws [UnimplementedError] on all methods until Phase 6.2.
class StubEmbeddingEngine implements AbstractEmbeddingEngine {
  const StubEmbeddingEngine();

  @override
  Future<EmbeddingVector> generateEmbedding(String text) {
    throw UnimplementedError('Embedding generation will be implemented in Phase 6.2');
  }

  @override
  Future<List<EmbeddingVector>> generateBatchEmbeddings(List<String> texts) {
    throw UnimplementedError('Batch embedding generation will be implemented in Phase 6.2');
  }
}
