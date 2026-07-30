/// Low-level exceptions thrown by AI implementations.
class AIException implements Exception {

  const AIException(this.message, [this.cause]);
  final String message;
  final dynamic cause;

  @override
  String toString() => 'AIException: $message ${cause != null ? '(Cause: $cause)' : ''}';
}

class EmbeddingException extends AIException {
  const EmbeddingException(super.message, [super.cause]);
}

class InferenceException extends AIException {
  const InferenceException(super.message, [super.cause]);
}

class VectorStoreException extends AIException {
  const VectorStoreException(super.message, [super.cause]);
}
