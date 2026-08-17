// End-to-end regression for the defect diagnosed on the Realme 12 Pro 5G:
// a workspace whose only document is a PDF returned "No results found".
//
// Unlike keyword_search_indexing_test (which uses a fake text engine), this
// test wires the REAL TextEngineImpl through the REAL ParserRegistry, so the
// path that was broken — PdfParser text extraction feeding lazy indexing —
// is exercised for real against a genuine on-disk PDF. Only the SQLite index
// store and the candidate repository are faked (the IO/persistence boundary).

import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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

const _kDocId = 'pdf-doc-1';
const _kWorkspaceId = 'ws-1';

/// Builds a genuine text-based PDF on disk and returns its metadata.
Future<DocumentMetadata> _writePdf(List<String> lines, String name) async {
  final document = PdfDocument();
  final page = document.pages.add();
  final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
  var y = 0.0;
  for (final line in lines) {
    page.graphics.drawString(line, font,
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(0, y, 500, 20));
    y += 20;
  }
  final bytes = document.saveSync();
  document.dispose();

  final dir = await Directory.systemTemp.createTemp('aura_pdf_search_');
  final path = '${dir.path}/$name';
  await File(path).writeAsBytes(bytes, flush: true);

  return DocumentMetadata(
    id: _kDocId,
    workspaceId: _kWorkspaceId,
    fileName: name,
    fileExtension: 'pdf',
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
  int saveCount = 0;

  @override
  Future<void> saveIndex(SearchIndex index) async {
    store[index.documentId] = index;
    saveCount++;
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
  group('PDF content search (real parser + engine)', () {
    test('a PDF is lazily indexed and a body term matches', () async {
      final pdf = await _writePdf(const [
        'Quarterly budget review covering infrastructure spending.',
        'Procurement approval is required before headcount planning.',
      ], 'report.pdf');
      final h = _build([pdf]);

      expect(h.indexRepository.store, isEmpty,
          reason: 'precondition: nothing indexed yet');

      final results =
          await h.engine.search(const SearchQuery(keyword: 'procurement'));

      expect(results, hasLength(1),
          reason: 'the PDF body term must reach the index — the exact path '
              'that threw "Unsupported text format: pdf" on device');
      expect(results.first.metadata.id, _kDocId);
      expect(results.first.score, greaterThan(0));
      expect(h.indexRepository.store.containsKey(_kDocId), isTrue,
          reason: 'the on-demand PDF index must persist');
    });

    test('a term absent from the PDF returns nothing, but it is still indexed',
        () async {
      final pdf = await _writePdf(const ['Budget and infrastructure notes.'],
          'report2.pdf');
      final h = _build([pdf]);

      final results =
          await h.engine.search(const SearchQuery(keyword: 'zebra'));

      expect(results, isEmpty);
      expect(h.indexRepository.store.containsKey(_kDocId), isTrue,
          reason: 'a PDF with no matching term is indexed, it just does not '
              'match');
    });
  });
}
