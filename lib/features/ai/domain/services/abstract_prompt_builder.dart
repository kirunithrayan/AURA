/// Abstract interface for dynamically constructing LLM prompts with context.
abstract class AbstractPromptBuilder {
  /// Builds a complete prompt string from a base template and injected context.
  String buildPrompt({
    required String templateName,
    required Map<String, dynamic> variables,
  });
}
