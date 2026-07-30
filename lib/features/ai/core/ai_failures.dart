import '../../../../core/error/failures.dart';

/// Base failure for the AI subsystem.
abstract class AIFailure extends Failure {
  const AIFailure(super.message);
}

class EmbeddingFailure extends AIFailure {
  const EmbeddingFailure(super.message);
}

class InferenceFailure extends AIFailure {
  const InferenceFailure(super.message);
}

class VectorStoreFailure extends AIFailure {
  const VectorStoreFailure(super.message);
}

class ChunkingFailure extends AIFailure {
  const ChunkingFailure(super.message);
}

class PromptFailure extends AIFailure {
  const PromptFailure(super.message);
}

class ModelLoadingFailure extends AIFailure {
  const ModelLoadingFailure(super.message);
}

class ContextFailure extends AIFailure {
  const ContextFailure(super.message);
}
