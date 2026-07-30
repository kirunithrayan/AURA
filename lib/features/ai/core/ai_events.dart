import 'package:equatable/equatable.dart';

/// Base class for all AI telemetry events.
abstract class AIEvent extends Equatable {
  const AIEvent();

  @override
  List<Object?> get props => [];
}

class AIInitialized extends AIEvent {
  const AIInitialized();
}

class EmbeddingGenerated extends AIEvent {

  const EmbeddingGenerated({
    required this.modelName,
    required this.tokenCount,
    required this.durationMs,
  });
  final String modelName;
  final int tokenCount;
  final int durationMs;

  @override
  List<Object?> get props => [modelName, tokenCount, durationMs];
}

class EmbeddingCached extends AIEvent {

  const EmbeddingCached(this.cacheKey);
  final String cacheKey;

  @override
  List<Object?> get props => [cacheKey];
}

class ChunkCreated extends AIEvent {

  const ChunkCreated(this.documentId, this.chunkIndex);
  final String documentId;
  final int chunkIndex;

  @override
  List<Object?> get props => [documentId, chunkIndex];
}

class ChunkIndexed extends AIEvent {

  const ChunkIndexed(this.documentId);
  final String documentId;

  @override
  List<Object?> get props => [documentId];
}

class VectorStored extends AIEvent {

  const VectorStored(this.vectorId);
  final String vectorId;

  @override
  List<Object?> get props => [vectorId];
}

class VectorDeleted extends AIEvent {

  const VectorDeleted(this.vectorId);
  final String vectorId;

  @override
  List<Object?> get props => [vectorId];
}

class InferenceStarted extends AIEvent {

  const InferenceStarted({
    required this.modelName,
    required this.promptContext,
  });
  final String modelName;
  final String promptContext;

  @override
  List<Object?> get props => [modelName, promptContext];
}

class InferenceCompleted extends AIEvent {

  const InferenceCompleted({
    required this.modelName,
    required this.durationMs,
  });
  final String modelName;
  final int durationMs;

  @override
  List<Object?> get props => [modelName, durationMs];
}

class InferenceFailed extends AIEvent {

  const InferenceFailed({
    required this.modelName,
    required this.errorMessage,
  });
  final String modelName;
  final String errorMessage;

  @override
  List<Object?> get props => [modelName, errorMessage];
}

class PromptGenerated extends AIEvent {

  const PromptGenerated(this.templateName);
  final String templateName;

  @override
  List<Object?> get props => [templateName];
}

class ModelLoaded extends AIEvent {

  const ModelLoaded(this.modelName, this.memoryBytes);
  final String modelName;
  final int memoryBytes;

  @override
  List<Object?> get props => [modelName, memoryBytes];
}

class ModelUnloaded extends AIEvent {

  const ModelUnloaded(this.modelName);
  final String modelName;

  @override
  List<Object?> get props => [modelName];
}
