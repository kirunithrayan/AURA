import 'package:flutter/services.dart' show rootBundle;
import '../../domain/services/embedding_service.dart';

/// Thrown when semantic embedding is requested but no model is available.
class EmbeddingModelUnavailableException implements Exception {
  const EmbeddingModelUnavailableException(this.reason);

  final String reason;

  @override
  String toString() => 'Embedding model unavailable: $reason';
}

/// [EmbeddingService] intended to run a sentence-transformer model on device
/// via ONNX Runtime.
///
/// ## Status: not yet functional
///
/// This service is deliberately non-operational. Two pieces are missing:
///
///   1. **The model file.** `assets/models/all-MiniLM-L6-v2.onnx` is not
///      present in the repository.
///   2. **A tokenizer.** MiniLM expects WordPiece `input_ids`, `attention_mask`
///      and `token_type_ids`. Dart has no HuggingFace tokenizer port, so one
///      must be written against the model's `vocab.txt` before inference can
///      run.
///
/// Until both exist, every call throws [EmbeddingModelUnavailableException].
/// This is intentional. An earlier revision returned synthetic vectors derived
/// from `text.hashCode`; because every component was non-negative and followed
/// the same ramp, any two unrelated documents scored ~0.75 cosine similarity —
/// above the 0.55 relevance threshold — so semantic search matched everything
/// and silently poisoned hybrid ranking with noise. Failing loudly is correct:
/// [SemanticSearchEngine] catches this and returns no results, so hybrid search
/// degrades cleanly to keyword-only.
///
/// To activate: add the model and vocab to `assets/models/`, implement the
/// tokenizer, then replace [generateEmbedding] with a real `session.run()`.
class OnnxEmbeddingService implements EmbeddingService {

  OnnxEmbeddingService({this.modelPath = 'assets/models/all-MiniLM-L6-v2.onnx'});

  final String modelPath;

  bool _initialized = false;
  bool _modelPresent = false;

  /// Whether a usable model is loaded. Always `false` until the model file and
  /// tokenizer described in the class docs are added.
  bool get isAvailable => false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await rootBundle.load(modelPath);
      _modelPresent = true;
    } catch (_) {
      _modelPresent = false;
    }

    _initialized = true;
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    await initialize();

    throw EmbeddingModelUnavailableException(
      _modelPresent
          ? 'Model found at $modelPath, but no WordPiece tokenizer is '
              'implemented, so it cannot be run.'
          : 'No model at $modelPath. On-device embeddings are not yet enabled.',
    );
  }

  @override
  Future<List<List<double>>> generateEmbeddingsBatch(List<String> texts) async {
    final results = <List<double>>[];
    for (final text in texts) {
      results.add(await generateEmbedding(text));
    }
    return results;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
    _modelPresent = false;
  }
}
