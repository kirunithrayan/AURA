// Covers the path from a keyword search hit through to the AI provider.
//
// The existing rag_service_test mocks the context builder, so it cannot see
// whether a real search result actually produces context. That is exactly how
// the pipeline shipped broken: search returned nothing, context was empty, and
// RAGServiceImpl returned its fallback message without ever constructing a
// provider. These tests use the REAL context builder and the REAL prompt
// builder, and assert on whether the provider is reached.

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/ai/rag/data/services/rag_service_impl.dart';
import 'package:aura/features/ai/rag/data/services/keyword_context_builder_service.dart';
import 'package:aura/features/ai/rag/data/services/prompt_builder_service_impl.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_config.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_stream_event.dart';
import 'package:aura/features/ai/rag/domain/providers/ai_provider.dart';
import 'package:aura/features/ai/rag/domain/providers/ai_provider_factory.dart';
import 'package:aura/features/search/domain/engines/abstract_search_engine.dart';
import 'package:aura/features/search/domain/entities/search_query.dart';
import 'package:aura/features/search/domain/entities/search_result.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';

DocumentMetadata _meta(String id, String fileName) => DocumentMetadata(
      id: id,
      workspaceId: 'ws-1',
      fileName: fileName,
      fileExtension: 'txt',
      filePath: '/tmp/$fileName',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

SearchResult _hit(String id, String fileName, double score, String snippet) =>
    SearchResult(
      metadata: _meta(id, fileName),
      score: score,
      snippet: snippet,
      searchEngineType: 'keyword',
    );

class _FakeSearchEngine implements AbstractSearchEngine {
  _FakeSearchEngine(this.results);

  final List<SearchResult> results;
  SearchQuery? lastQuery;

  @override
  String get engineType => 'keyword';

  @override
  Future<List<SearchResult>> search(SearchQuery query) async {
    lastQuery = query;
    return results;
  }
}

class _RecordingProvider implements AiProvider {
  _RecordingProvider(this.config);

  @override
  final AiConfig config;

  final List<String> prompts = [];

  @override
  Future<String> generateContent(String prompt) async {
    prompts.add(prompt);
    return 'model answer';
  }

  @override
  Stream<AiStreamEvent> streamGenerateContent(String prompt) async* {
    prompts.add(prompt);
    yield const AiStreamToken('model ');
    yield const AiStreamToken('answer');
    yield const AiStreamComplete('model answer');
  }
}

class _RecordingFactory implements AiProviderFactory {
  _RecordingProvider? created;

  @override
  AiProvider createProvider(AiConfig config) =>
      created = _RecordingProvider(config);
}

RAGServiceImpl _service(_FakeSearchEngine engine, _RecordingFactory factory) =>
    RAGServiceImpl(
      engine,
      const KeywordContextBuilderService(),
      PromptBuilderServiceImpl(),
      factory,
    );

const _config = AiConfig(apiKey: 'test-key');

void main() {
  group('keyword RAG pipeline', () {
    test('a keyword hit reaches the AI provider', () async {
      final engine = _FakeSearchEngine([
        _hit('doc-1', 'budget.txt', 30.0,
            'The quarterly budget review covers infrastructure spending.'),
      ]);
      final factory = _RecordingFactory();

      final response =
          await _service(engine, factory).askDocument('budget', _config);

      expect(factory.created, isNotNull,
          reason: 'the provider must actually be constructed');
      expect(factory.created!.prompts, hasLength(1));
      expect(factory.created!.prompts.single, contains('quarterly budget'));
      expect(response.text, 'model answer');
      expect(response.citations, hasLength(1));
      expect(response.citations.first.fileName, 'budget.txt');
    });

    test('the top hit always survives the similarity threshold', () async {
      // Keyword scores are unbounded and unrelated to the 0..1 threshold.
      // A weak raw score must still normalise to 1.0 and get through.
      final engine = _FakeSearchEngine([
        _hit('doc-1', 'notes.txt', 1.5, 'a faint but real mention of budget'),
      ]);
      final factory = _RecordingFactory();

      final response = await _service(engine, factory)
          .askDocument('budget', const AiConfig(apiKey: 'k', similarityThreshold: 0.9));

      expect(factory.created, isNotNull);
      expect(response.text, 'model answer');
    });

    test('no search results means no provider call and a fallback answer',
        () async {
      final engine = _FakeSearchEngine([]);
      final factory = _RecordingFactory();

      final response =
          await _service(engine, factory).askDocument('budget', _config);

      expect(factory.created, isNull,
          reason: 'nothing to ground an answer in, so do not call the model');
      expect(response.text, contains("couldn't find"));
      expect(response.citations, isEmpty);
    });

    test('streaming reaches the provider and accumulates tokens', () async {
      final engine = _FakeSearchEngine([
        _hit('doc-1', 'budget.txt', 30.0, 'budget review notes'),
      ]);
      final factory = _RecordingFactory();

      final responses = await _service(engine, factory)
          .streamAskDocument('budget', _config)
          .toList();

      expect(factory.created, isNotNull);
      expect(responses.last.text, 'model answer');
      expect(responses.last.citations, hasLength(1));
    });
  });

  group('KeywordContextBuilderService', () {
    const builder = KeywordContextBuilderService();

    test('normalises scores relative to the top hit', () async {
      final chunks = await builder.buildContext([
        _hit('doc-1', 'a.txt', 30.0, 'strongest match'),
        _hit('doc-2', 'b.txt', 15.0, 'half as strong'),
      ]);

      expect(chunks, hasLength(2));
      expect(chunks.first.similarityScore, 1.0);
      expect(chunks.last.similarityScore, closeTo(0.5, 0.001));
    });

    test('orders by score regardless of input order', () async {
      final chunks = await builder.buildContext([
        _hit('doc-1', 'weak.txt', 2.0, 'weak match'),
        _hit('doc-2', 'strong.txt', 40.0, 'strong match'),
      ]);

      expect(chunks.first.fileName, 'strong.txt');
      expect(chunks.first.similarityScore, 1.0);
    });

    test('skips results with no snippet text', () async {
      final chunks = await builder.buildContext([
        _hit('doc-1', 'a.txt', 30.0, '   '),
        SearchResult(
          metadata: _meta('doc-2', 'b.txt'),
          score: 20.0,
          searchEngineType: 'keyword',
        ),
        _hit('doc-3', 'c.txt', 10.0, 'real text'),
      ]);

      expect(chunks, hasLength(1));
      expect(chunks.single.fileName, 'c.txt');
    });

    test('keeps one chunk per document', () async {
      final chunks = await builder.buildContext([
        _hit('doc-1', 'a.txt', 30.0, 'best window'),
        _hit('doc-1', 'a.txt', 12.0, 'weaker window in the same file'),
      ]);

      expect(chunks, hasLength(1));
      expect(chunks.single.textSnippet, 'best window');
    });

    test('respects the token budget but never returns empty', () async {
      final long = 'x' * 8000; // ~2000 approx tokens each
      final chunks = await builder.buildContext(
        [
          _hit('doc-1', 'a.txt', 30.0, long),
          _hit('doc-2', 'b.txt', 20.0, long),
        ],
        maxLength: 100,
      );

      expect(chunks, hasLength(1),
          reason: 'the top chunk is admitted even when it blows the budget');
      expect(chunks.single.fileName, 'a.txt');
    });

    test('an empty result set produces no context', () async {
      expect(await builder.buildContext([]), isEmpty);
    });

    test('a non-positive top score does not break normalisation', () async {
      final chunks = await builder.buildContext([
        _hit('doc-1', 'a.txt', 0.0, 'zero scored hit'),
      ]);

      expect(chunks, hasLength(1));
      expect(chunks.single.similarityScore, 0.0);
    });
  });
}
