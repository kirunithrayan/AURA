import '../../core/constants/app_constants.dart';

/// Configuration for the Embedding Engine.
class EmbeddingConfig {
  final String modelPath;
  final String modelVersion;
  final int dimensions;
  final String quantizationType;
  final int maxSequenceLength;

  const EmbeddingConfig({
    required this.modelPath,
    required this.modelVersion,
    this.dimensions = AppConstants.defaultEmbeddingDimensions,
    this.quantizationType = 'INT8',
    this.maxSequenceLength = AppConstants.maxChunkSize,
  });
}
