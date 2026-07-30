import '../../domain/services/abstract_prompt_builder.dart';

/// Stub implementation of [AbstractPromptBuilder] for DI registration.
class StubPromptBuilder implements AbstractPromptBuilder {
  const StubPromptBuilder();

  @override
  String buildPrompt({
    required String templateName,
    required Map<String, dynamic> variables,
  }) {
    throw UnimplementedError('Prompt building will be implemented in a future phase');
  }
}
