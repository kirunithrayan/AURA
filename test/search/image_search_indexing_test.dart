// End-to-end regression for the image-search defect diagnosed on the Realme
// 12 Pro 5G: a workspace whose only document is an image returned "No results
// found" — even for the exact filename.
//
// Like pdf_search_indexing_test (and unlike keyword_search_indexing_test's
// fake text engine), this wires the REAL TextEngineImpl through the REAL
// ParserRegistry, so the path that threw "Unsupported text format: png" is
// exercised for real against a genuine on-disk PNG. Only the SQLite index
// store and the candidate repository are faked (the IO/persistence boundary).
// The parser result is NOT faked — ImageParser runs for real and returns its
// empty-content, filename-titled document, which is exactly what makes the
// filename match reachable.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/text_engine/text_engine_impl.dart';
import 'package:aura/features/document_viewer/data/cache/document_cache.dart';
import 'package:aura/features/search/data/engines/keyword_search_engine.dart';
import 'package:aura/features/search/data/engines/query/query_processor.dart';
import 'package:aura/features/search/data/engines/matching/matching_strategy.dart';
import 'package:aura/features/search/data/engines/snippet/search_snippet_generator.dart';
import 'package:aura/features/search/data/indexing/cache/search_index_cache.dart';
import 'package:aura/features/search/data/indexing/repositories/search_index_repository.dart';
import 'package:aura/features/search/data/indexing/search_index_service.dart';
import 'package:aura/features/search/data/indexing/search_index_logger.dart';
import 'package:aura/features/search/data/indexing/builder/default_index_builder.dart';
import 'package:aura/features/search/data/indexing/tokenizer/default_tokenizer.dart';
import 'package:aura/features/search/data/indexing/normalizer/default_token_normalizer.dart';
import 'package:aura/features/search/data/indexing/filter/default_stop_word_filter.dart';
import 'package:aura/features/search/domain/entities/indexing/search_index.dart';
import 'package:aura/features/search/domain/entities/indexing/search_index_statistics.dart';
import 'package:aura/features/search/domain/entities/search_query.dart';
import 'package:aura/features/search/domain/entities/search_statistics.dart';
import 'package:aura/features/search/domain/entities/search_log_context.dart';
import 'package:aura/features/search/domain/entities/search_event.dart';
import 'package:aura/features/search/domain/repositories/search_repository.dart';
import 'package:aura/features/search/domain/repositories/search_logger.dart';
import 'package:aura/features/search/domain/repositories/search_event_bus.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';

const _kDocId = 'image-doc-1';
const _kWorkspaceId = 'ws-1';

/// The 67-byte canonical 1x1 transparent PNG. A genuine, valid image file —
/// not a stubbed parser result. ImageParser never reads these bytes (it does
/// not OCR), but writing a real file keeps the fixture honest.
final List<int> _png1x1 = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

Future<DocumentMetadata> _writeImage(String name, String extension) async {
  final dir = await Directory.systemTemp.createTemp('aura_image_search_');
  final path = '${dir.path}/$name';
  await File(path).writeAsBytes(_png1x1, flush: true);

  return DocumentMetadata(
    id: _kDocId,
    workspaceId: _kWorkspaceId,
    fileName: name,
    fileExtension: extension,
    filePath: path,
    createdAt: 0,
    modifiedAt: 0,
    importedAt: 0,
  );
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository(this.documents);
  final List<DocumentMetadata> documents;

  @override
  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async {
    final scoped = query.workspaceId == null
        ? documents
        : documents.where((d) => d.workspaceId == query.workspaceId).toList();
    return scoped.take(query.limit).toList();
  }
}

class _InMemoryIndexRepository implements SearchIndexRepository {
  final Map<String, SearchIndex> store = {};

  @override
  Future<void> saveIndex(SearchIndex index) async {
    store[index.documentId] = index;
  }

  @override
  Future<SearchIndex?> getIndex(String documentId) async => store[documentId];

  @override
  Future<void> deleteIndex(String documentId) async => store.remove(documentId);

  @override
  Future<({String? checksum, String? parserVersion})?> getIndexMeta(
      String documentId) async {
    final index = store[documentId];
    if (index == null) return null;
    return (checksum: index.checksum, parserVersion: index.parserVersion);
  }

  @override
  Future<List<String>> getIndexedDocumentIds(String workspaceId) async =>
      store.keys.toList();
}

class _SilentLogger implements SearchLogger {
  @override
  Future<void> logSearch(SearchQuery query, SearchStatistics stats) async {}
  @override
  Future<void> logFailure(SearchQuery query, String error) async {}
  @override
  Future<void> logCacheEvent(String queryId, String cacheKey, bool hit) async {}
  @override
  Future<void> logOptimization(
      String type, Duration duration, Map<String, dynamic> meta) async {}
  @override
  Future<void> logBatchEvent(String jobId, String status,
      {int? processed, int? failed, String? error}) async {}
  @override
  Future<void> logWithContext(SearchLogContext context,
      {Map<String, dynamic>? extraData, String? errorMessage}) async {}
}

class _SilentIndexLogger implements SearchIndexLogger {
  @override
  void logIndexed(String documentId, SearchIndexStatistics stats) {}
  @override
  void logSkipped(String documentId, String reason) {}
  @override
  void logFailure(String documentId, String error) {}
}

class _SilentEventBus implements SearchEventBus {
  @override
  void publish(SearchEvent event) {}
  @override
  Stream<SearchEvent> get events => const Stream.empty();
}

({KeywordSearchEngine engine, _InMemoryIndexRepository indexRepository})
    _build(List<DocumentMetadata> documents) {
  const tokenizer = DefaultTokenizer();
  const normalizer = DefaultTokenNormalizer();
  final stopWords = DefaultStopWordFilter();

  final indexRepository = _InMemoryIndexRepository();
  final indexCache = SearchIndexCache();
  final textEngine = TextEngineImpl(DocumentCache());
  final repository = _FakeSearchRepository(documents);

  final indexService = SearchIndexService(
    textEngine,
    DefaultIndexBuilder(tokenizer, normalizer, stopWords),
    indexRepository,
    indexCache,
    _SilentEventBus(),
    _SilentIndexLogger(),
  );

  final engine = KeywordSearchEngine(
    repository,
    indexRepository,
    indexCache,
    DefaultQueryProcessor(tokenizer, normalizer, stopWords),
    const DefaultMatchingStrategy(),
    const SearchSnippetGenerator(),
    textEngine,
    _SilentLogger(),
    indexService,
  );

  return (engine: engine, indexRepository: indexRepository);
}

void main() {
  group('Image filename search (real parser + engine)', () {
    test('an image is lazily indexed and found by a filename term', () async {
      final image = await _writeImage('aura_diagram_notes.png', 'png');
      final h = _build([image]);

      expect(h.indexRepository.store, isEmpty,
          reason: 'precondition: nothing indexed yet');

      final results =
          await h.engine.search(const SearchQuery(keyword: 'diagram'));

      expect(results, hasLength(1),
          reason: 'the image filename term must reach the matcher — the exact '
              'path that threw "Unsupported text format: png" on device');
      expect(results.first.metadata.id, _kDocId);
      expect(results.first.score, greaterThan(0));
      expect(h.indexRepository.store.containsKey(_kDocId), isTrue,
          reason: 'the on-demand image index must persist (even with empty '
              'content) so later searches do not re-parse');
    });

    test('the persisted image index has empty content (no OCR happened)',
        () async {
      final image = await _writeImage('aura_diagram_notes.png', 'png');
      final h = _build([image]);

      await h.engine.search(const SearchQuery(keyword: 'diagram'));

      final index = h.indexRepository.store[_kDocId];
      expect(index, isNotNull);
      // The image contributes only its title/filename to the index; there is
      // no body content, proving OCR was not silently introduced.
      expect(index!.entries.every((e) => e.field == 'title'), isTrue,
          reason: 'only filename/title tokens should be indexed for an image');
    });

    test('a term absent from the filename returns nothing, but the image is '
        'still indexed', () async {
      final image = await _writeImage('aura_diagram_notes.png', 'png');
      final h = _build([image]);

      final results =
          await h.engine.search(const SearchQuery(keyword: 'procurement'));

      expect(results, isEmpty);
      expect(h.indexRepository.store.containsKey(_kDocId), isTrue,
          reason: 'an image whose filename does not match is still indexed, it '
              'just does not match');
    });

    test('webp images are indexed and found by filename too', () async {
      final image = await _writeImage('aura_diagram_notes.webp', 'webp');
      final h = _build([image]);

      final results =
          await h.engine.search(const SearchQuery(keyword: 'diagram'));

      expect(results, hasLength(1));
      expect(results.first.metadata.id, _kDocId);
    });
  });
}
