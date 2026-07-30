import '../../domain/services/abstract_vector_store.dart';
import '../../domain/entities/embedding_vector.dart';
import '../../domain/entities/vector_search_result.dart';

/// Stub implementation of [AbstractVectorStore] for DI registration.
class StubVectorStore implements AbstractVectorStore {
  const StubVectorStore();

  @override
  Future<void> store(EmbeddingVector vector, Map<String, dynamic> metadata) {
    throw UnimplementedError('Vector storage will be implemented in Phase 6.2');
  }

  @override
  Future<void> update(EmbeddingVector vector, Map<String, dynamic> metadata) {
    throw UnimplementedError('Vector update will be implemented in Phase 6.2');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('Vector deletion will be implemented in Phase 6.2');
  }

  @override
  Future<List<VectorSearchResult>> search(List<double> queryVector, {int topK = 10}) {
    throw UnimplementedError('Vector search will be implemented in Phase 6.2');
  }

  @override
  Future<void> clear() {
    throw UnimplementedError('Vector clear will be implemented in Phase 6.2');
  }
}
