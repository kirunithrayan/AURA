import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:aura/features/ai/rag/domain/services/context_builder_service.dart';
import 'package:aura/features/ai/rag/domain/services/prompt_builder_service.dart';
import 'package:aura/features/ai/rag/domain/providers/ai_provider_factory.dart';
import 'package:aura/features/search/domain/engines/abstract_search_engine.dart';
import 'package:aura/features/ai/rag/data/services/rag_service_impl.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_config.dart';
import 'package:aura/features/ai/rag/domain/providers/ai_provider.dart';
import 'package:aura/features/ai/rag/domain/entities/context_chunk.dart';
import 'package:aura/features/search/domain/entities/search_query.dart';
import 'rag_service_test.mocks.dart';

@GenerateMocks([
  AbstractSearchEngine,
  ContextBuilderService,
  PromptBuilderService,
  AiProviderFactory,
  AiProvider,
])
void main() {
  group('RAGService', () {
    late MockAbstractSearchEngine mockSearchEngine;
    late MockContextBuilderService mockContextBuilder;
    late MockPromptBuilderService mockPromptBuilder;
    late MockAiProviderFactory mockProviderFactory;
    late MockAiProvider mockProvider;
    late RAGServiceImpl service;

    setUp(() {
      mockSearchEngine = MockAbstractSearchEngine();
      mockContextBuilder = MockContextBuilderService();
      mockPromptBuilder = MockPromptBuilderService();
      mockProviderFactory = MockAiProviderFactory();
      mockProvider = MockAiProvider();
      
      service = RAGServiceImpl(
        mockSearchEngine,
        mockContextBuilder,
        mockPromptBuilder,
        mockProviderFactory,
      );
    });

    test('should orchestrate search and generation', () async {
      const config = AiConfig(apiKey: 'test', providerName: 'stub');
      
      when(mockSearchEngine.search(any)).thenAnswer((_) async => []);
      
      when(mockContextBuilder.buildContext(any)).thenAnswer((_) async => [
        const ContextChunk(
          documentId: 'doc1',
          workspaceId: 'ws1',
          fileName: 'doc1.pdf',
          chunkIndex: 0,
          textSnippet: 'snippet',
          similarityScore: 0.9,
        )
      ]);
      
      when(mockPromptBuilder.buildPrompt(any, any)).thenReturn('prompt');
      when(mockProviderFactory.createProvider(any)).thenReturn(mockProvider);
      when(mockProvider.generateContent('prompt')).thenAnswer((_) async => 'generated response');

      final response = await service.askDocument('query', config);

      expect(response.text, 'generated response');
      expect(response.citations.length, 1);
      expect(response.citations.first.similarityScore, 0.9);
      
      verify(mockSearchEngine.search(const SearchQuery(keyword: 'query'))).called(1);
      verify(mockContextBuilder.buildContext(any)).called(1);
      verify(mockPromptBuilder.buildPrompt('query', any)).called(1);
      verify(mockProviderFactory.createProvider(config)).called(1);
      verify(mockProvider.generateContent('prompt')).called(1);
    });
    
    test('should fallback when chunks are below threshold', () async {
      const config = AiConfig(apiKey: 'test', providerName: 'stub', similarityThreshold: 0.95);
      
      when(mockSearchEngine.search(any)).thenAnswer((_) async => []);
      
      when(mockContextBuilder.buildContext(any)).thenAnswer((_) async => [
        const ContextChunk(
          documentId: 'doc1',
          workspaceId: 'ws1',
          fileName: 'doc1.pdf',
          chunkIndex: 0,
          textSnippet: 'snippet',
          similarityScore: 0.9, // Below threshold of 0.95
        )
      ]);
      
      when(mockPromptBuilder.getFallbackMessage()).thenReturn('fallback msg');

      final response = await service.askDocument('query', config);

      expect(response.text, 'fallback msg');
      expect(response.citations.isEmpty, true);
      
      // Should not call AI provider
      verifyNever(mockProviderFactory.createProvider(any));
    });
  });
}
