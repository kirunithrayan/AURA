import '../entities/context_chunk.dart';

abstract class PromptBuilderService {
  /// Builds a complete prompt using the user's query and the provided context.
  String buildPrompt(String query, List<ContextChunk> context);

  /// Returns a fallback message to display when no relevant context is found.
  String getFallbackMessage();
}
