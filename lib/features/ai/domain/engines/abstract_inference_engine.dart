/// Abstract interface for generating text responses from large language models (LLMs).
abstract class AbstractInferenceEngine {
  /// Generates a complete response synchronously (awaits full completion).
  Future<String> generateResponse(String prompt);

  /// Streams the response piece-by-piece as it is generated.
  Stream<String> streamResponse(String prompt);
}
