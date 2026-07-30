import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/ai/rag/data/services/prompt_builder_service_impl.dart';
import 'package:aura/features/ai/rag/domain/entities/context_chunk.dart';

void main() {
  group('PromptBuilderService', () {
    late PromptBuilderServiceImpl service;

    setUp(() {
      service = PromptBuilderServiceImpl();
    });

    test('should build a prompt containing context snippets and query', () {
      final context = [
        const ContextChunk(
          documentId: 'doc1',
          workspaceId: 'ws1',
          fileName: 'file1.txt',
          chunkIndex: 0,
          textSnippet: 'This is the first piece of context.',
          similarityScore: 0.9,
        ),
        const ContextChunk(
          documentId: 'doc2',
          workspaceId: 'ws1',
          fileName: 'file2.txt',
          chunkIndex: 5,
          textSnippet: 'This is another piece of context.',
          similarityScore: 0.8,
        ),
      ];

      final prompt = service.buildPrompt('What is this?', context);

      expect(prompt, contains('This is the first piece of context.'));
      expect(prompt, contains('This is another piece of context.'));
      expect(prompt, contains('[1] (File: file1.txt)'));
      expect(prompt, contains('[2] (File: file2.txt)'));
      expect(prompt, contains('What is this?'));
      expect(prompt, contains('ONLY on the provided context'));
    });

    test('should return standard fallback message', () {
      final msg = service.getFallbackMessage();
      expect(msg, contains("couldn't find any relevant information"));
    });
  });
}
