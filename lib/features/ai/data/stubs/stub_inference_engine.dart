import '../../domain/engines/abstract_inference_engine.dart';

/// Stub implementation of [AbstractInferenceEngine] for DI registration.
/// Throws [UnimplementedError] on all methods until Phase 6.
class StubInferenceEngine implements AbstractInferenceEngine {
  const StubInferenceEngine();

  @override
  Future<String> generateResponse(String prompt) {
    throw UnimplementedError('Inference will be implemented in a future phase');
  }

  @override
  Stream<String> streamResponse(String prompt) {
    throw UnimplementedError('Streaming inference will be implemented in a future phase');
  }
}
