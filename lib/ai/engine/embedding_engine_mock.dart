import 'dart:math';
import '../models/embedding_result.dart';
import 'embedding_engine.dart';
import '../../core/constants/app_constants.dart';

/// A mock implementation of the EmbeddingEngine for Phase 1 testing.
/// Generates deterministic pseudo-random vectors.
class MockEmbeddingEngine implements EmbeddingEngine {
  static const String _version = 'mock_v1';
  final int _dimensions = AppConstants.defaultEmbeddingDimensions;
  
  @override
  Future<void> initialize() async {
    // Simulate load time
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<EmbeddingResult> generateEmbedding(String text) async {
    final startTime = DateTime.now();
    
    // Deterministic random based on string hash for consistent mock results
    final random = Random(text.hashCode);
    
    // Simulate processing time based on text length
    await Future.delayed(Duration(milliseconds: 10 + (text.length % 50)));

    final vector = List.generate(_dimensions, (_) => random.nextDouble() * 2 - 1);
    
    // Normalize vector
    double norm = 0.0;
    for (var val in vector) {
      norm += val * val;
    }
    norm = sqrt(norm);
    for (int i = 0; i < vector.length; i++) {
      vector[i] = vector[i] / norm;
    }

    return EmbeddingResult(
      vector: vector,
      modelVersion: _version,
      dimensions: _dimensions,
      processingTimeMs: DateTime.now().difference(startTime).inMilliseconds,
    );
  }

  @override
  Future<List<EmbeddingResult>> generateBatchEmbeddings(List<String> texts) async {
    return Future.wait(texts.map((t) => generateEmbedding(t)));
  }

  @override
  String getModelVersion() => _version;

  @override
  int getDimensions() => _dimensions;

  @override
  Future<void> dispose() async {
    // Nothing to dispose
  }
}
