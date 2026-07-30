import '../../domain/services/prompt_builder_service.dart';
import '../../domain/entities/context_chunk.dart';

class PromptBuilderServiceImpl implements PromptBuilderService {
  @override
  String buildPrompt(String query, List<ContextChunk> context) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are AURA, an intelligent AI assistant. Your task is to answer the user\'s question based ONLY on the provided context.');
    buffer.writeln('If the answer is not contained in the context, you must reply: "I cannot answer this based on the provided documents." Do not use outside knowledge.');
    buffer.writeln('\nWhen using information from the context, you must cite the source by appending the source index in brackets, like [1] or [2].');
    
    buffer.writeln('\n--- CONTEXT ---');
    for (int i = 0; i < context.length; i++) {
      final chunk = context[i];
      buffer.writeln('\nSource [${i + 1}] (File: ${chunk.fileName}):');
      buffer.writeln(chunk.textSnippet);
    }
    buffer.writeln('----------------\n');
    
    buffer.writeln('Question: $query');
    buffer.writeln('Answer:');
    
    return buffer.toString();
  }

  @override
  String getFallbackMessage() => "I couldn't find any relevant information in your documents to answer this question.";
}
