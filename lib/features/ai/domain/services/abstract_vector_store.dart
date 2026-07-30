import '../entities/embedding_vector.dart';
import '../entities/vector_search_result.dart';

/// Abstract interface for a Vector Database/Store infrastructure.
/// Note: This is an infrastructure service, not a domain repository,
/// as it directly maps to specialized storage engines (e.g. SQLite VSS, Isar).
abstract class AbstractVectorStore {
  /// Stores a new vector and its associated metadata.
  Future<void> store(EmbeddingVector vector, Map<String, dynamic> metadata);

  /// Updates an existing vector in the store.
  Future<void> update(EmbeddingVector vector, Map<String, dynamic> metadata);

  /// Deletes a vector from the store by its ID.
  Future<void> delete(String id);

  /// Performs a similarity search returning the closest topK vectors.
  Future<List<VectorSearchResult>> search(List<double> queryVector, {int topK = 10});

  /// Clears the entire vector store.
  Future<void> clear();
}
