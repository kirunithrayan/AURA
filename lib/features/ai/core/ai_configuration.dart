import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_configuration.freezed.dart';
part 'ai_configuration.g.dart';

/// Immutable configuration for the AI subsystem.
/// This configuration is designed to be future-proof and encompasses
/// all settings required for embeddings, chunking, inference, and retrieval.
@freezed
class AIConfiguration with _$AIConfiguration {
  const factory AIConfiguration({
    // Embedding configuration
    required String embeddingModelName,
    required int embeddingDimensions,
    required int embeddingBatchSize,

    // Chunking configuration
    required int chunkSize,
    required int chunkOverlap,

    // Inference configuration
    required int inferenceMaxTokens,
    required double inferenceTemperature,
    required double inferenceTopP,
    required int inferenceTopK,

    // Retrieval configuration
    required double similarityThreshold,
    required int maxRetrievalResults,

    // Performance configuration
    @Default(true) bool cacheEnabled,
    required int cacheSize,
    required int backgroundWorkers,

    // Debug configuration
    @Default(false) bool loggingEnabled,
  }) = _AIConfiguration;

  factory AIConfiguration.fromJson(Map<String, dynamic> json) => _$AIConfigurationFromJson(json);
}
