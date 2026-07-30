import 'dart:async';
import '../../domain/services/rag_service.dart';
import '../../domain/services/context_builder_service.dart';
import '../../domain/services/prompt_builder_service.dart';
import '../../domain/providers/ai_provider_factory.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/entities/citation.dart';
import '../../../../search/domain/engines/abstract_search_engine.dart';
import '../../../../search/domain/entities/search_query.dart';

class RAGServiceImpl implements RAGService {

  RAGServiceImpl(
    this._semanticSearchEngine,
    this._contextBuilder,
    this._promptBuilder,
    this._aiProviderFactory,
  );
  final AbstractSearchEngine _semanticSearchEngine;
  final ContextBuilderService _contextBuilder;
  final PromptBuilderService _promptBuilder;
  final AiProviderFactory _aiProviderFactory;

  @override
  Future<AiResponse> askDocument(String query, AiConfig config) async {
    final startTime = DateTime.now();

    // 1. Semantic Search
    final searchQuery = SearchQuery(keyword: query);
    final rawResults = await _semanticSearchEngine.search(searchQuery);

    // 2. Build Context
    final contextChunks = await _contextBuilder.buildContext(rawResults);

    // Filter by threshold
    final validChunks = contextChunks.where((c) => c.similarityScore >= config.similarityThreshold).toList();

    // 3. Check threshold fallback
    if (validChunks.isEmpty) {
      return AiResponse(
        text: _promptBuilder.getFallbackMessage(),
        provider: config.providerName,
        model: config.modelName,
        responseTime: DateTime.now().difference(startTime),
      );
    }

    // 4. Build Citations map
    final citations = validChunks.asMap().entries.map((e) => Citation(
        index: e.key + 1,
        documentId: e.value.documentId,
        workspaceId: e.value.workspaceId,
        fileName: e.value.fileName,
        snippet: e.value.textSnippet,
        chunkIndex: e.value.chunkIndex,
        similarityScore: e.value.similarityScore,
      )).toList();

    // 5. Build Prompt
    final prompt = _promptBuilder.buildPrompt(query, validChunks);

    // 6. Generate Content
    final provider = _aiProviderFactory.createProvider(config);
    final responseText = await provider.generateContent(prompt);

    return AiResponse(
      text: responseText,
      citations: citations,
      confidence: validChunks.first.similarityScore, // Using top match score as naive confidence
      provider: config.providerName,
      model: config.modelName,
      responseTime: DateTime.now().difference(startTime),
    );
  }

  @override
  Stream<AiResponse> streamAskDocument(String query, AiConfig config) async* {
    final startTime = DateTime.now();

    final searchQuery = SearchQuery(keyword: query);
    final rawResults = await _semanticSearchEngine.search(searchQuery);

    final contextChunks = await _contextBuilder.buildContext(rawResults);
    final validChunks = contextChunks.where((c) => c.similarityScore >= config.similarityThreshold).toList();

    if (validChunks.isEmpty) {
      yield AiResponse(
        text: _promptBuilder.getFallbackMessage(),
        provider: config.providerName,
        model: config.modelName,
        responseTime: DateTime.now().difference(startTime),
      );
      return;
    }

    final citations = validChunks.asMap().entries.map((e) => Citation(
        index: e.key + 1,
        documentId: e.value.documentId,
        workspaceId: e.value.workspaceId,
        fileName: e.value.fileName,
        snippet: e.value.textSnippet,
        chunkIndex: e.value.chunkIndex,
        similarityScore: e.value.similarityScore,
      )).toList();

    final prompt = _promptBuilder.buildPrompt(query, validChunks);
    final provider = _aiProviderFactory.createProvider(config);
    
    final stream = provider.streamGenerateContent(prompt);
    
    String accumulatedText = '';
    
    await for (final event in stream) {
      if (event is AiStreamToken) {
        accumulatedText += event.text;
        yield AiResponse(
          text: accumulatedText,
          citations: citations,
          confidence: validChunks.first.similarityScore,
          provider: config.providerName,
          model: config.modelName,
        );
      } else if (event is AiStreamComplete) {
        yield AiResponse(
          text: event.fullResponse,
          citations: citations,
          confidence: validChunks.first.similarityScore,
          provider: config.providerName,
          model: config.modelName,
          responseTime: DateTime.now().difference(startTime),
        );
      } else if (event is AiStreamError) {
        yield AiResponse(
          text: '$accumulatedText\n\n[Error: ${event.message}]',
          citations: citations,
          confidence: validChunks.first.similarityScore,
          provider: config.providerName,
          model: config.modelName,
          responseTime: DateTime.now().difference(startTime),
        );
      }
    }
  }
}
