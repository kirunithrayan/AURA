// Regression coverage for the search-index wiring.
//
// Background: KeywordSearchEngine can only match a document that has a
// persisted SearchIndex. Nothing in the app ever built one, so every real
// query returned zero results. Two wires fixed that — indexing on import, and
// indexing on demand here in the engine. These tests hold that shut.
//
// Everything except the persistence and IO boundary is real: the real query
// processor, matching strategy, snippet generator, index cache, index builder
// and SearchIndexService.

import 'package:flutter_test/flutter_test.dart';

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
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:aura/features/document_viewer/domain/entities/viewer_search_result.dart';
import 'package:aura/core/text_engine/abstract_text_document_engine.dart';
import 'package:aura/core/text_engine/models/text_document.dart';

const _kDocId = 'doc-1';
const _kWorkspaceId = 'ws-1';
const _kContent =
    'The quarterly budget review covers infrastructure spending and '
    'headcount planning for the next fiscal year. Budget approval is '
    'required before any procurement begins.';

// A second document in a different workspace, sharing no vocabulary with the
// first. Used to prove a body-only term matches only the document that
// actually contains it, and that workspace scoping still excludes candidates.
const _kDocId2 = 'doc-2';
const _kWorkspaceId2 = 'ws-2';
const _kContent2 =
    'Migratory patterns of the arctic tern span pole to pole. '
    'Ornithologists track the colony each season.';

DocumentMetadata _metadata() => const DocumentMetadata(
      id: _kDocId,
      workspaceId: _kWorkspaceId,
      fileName: 'notes.txt',
      fileExtension: 'txt',
      filePath: '/tmp/notes.txt',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

DocumentMetadata _metadata2() => const DocumentMetadata(
      id: _kDocId2,
      workspaceId: _kWorkspaceId2,
      fileName: 'seabirds.txt',
      fileExtension: 'txt',
      filePath: '/tmp/seabirds.txt',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

/// Models the real candidate contract: structural filters only.
///
/// The previous fake returned its document for every query regardless of
/// keyword, which happened to describe correct behaviour — so the suite stayed
/// green while the production datasource was filtering candidates by
/// `file_name LIKE %keyword%` and content search was dead on device. This one
/// applies the workspace filter for real and asserts the keyword is never
/// consulted, so the gap between fake and datasource cannot silently reopen.
class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository(this.documents);

  final List<DocumentMetadata> documents;
  final List<String> seenKeywords = [];

  @override
  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async {
    seenKeywords.add(query.keyword);
    final scoped = query.workspaceId == null
        ? documents
        : documents.where((d) => d.workspaceId == query.workspaceId).toList();
    return scoped.take(query.limit).toList();
  }
}

/// Stands in for the SQLite-backed index store.
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

class _FakeTextEngine implements AbstractTextDocumentEngine {
  _FakeTextEngine({this.throwOnOpen = false});

  final bool throwOnOpen;
  int openCount = 0;

  static const _contentById = {
    _kDocId: _kContent,
    _kDocId2: _kContent2,
  };

  @override
  Future<TextDocument> openDocument(WorkspaceFile file) async {
    openCount++;
    if (throwOnOpen) {
      throw const FileSystemException('file missing');
    }
    final content = _contentById[file.id] ?? _kContent;
    return TextDocument(
      title: file.fileName,
      content: content,
      headings: const [],
      paragraphCount: 1,
      wordCount: content.split(' ').length,
      characterCount: content.length,
      sourceType: 'txt',
      parserVersion: 'test-1',
    );
  }

  @override
  void close() {}
  @override
  TextDocument? getDocument() => null;
  @override
  Map<String, dynamic> getMetadata() => {};
  @override
  double getScrollPosition() => 0;
  @override
  void setScrollPosition(double position) {}
  @override
  ViewerSearchResult search(String keyword) =>
      throw UnimplementedError('not used by these tests');
}

class FileSystemException implements Exception {
  const FileSystemException(this.message);
  final String message;
  @override
  String toString() => 'FileSystemException: $message';
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

({
  KeywordSearchEngine engine,
  _InMemoryIndexRepository indexRepository,
  _FakeTextEngine textEngine,
  _FakeSearchRepository repository,
}) _build({
  bool textEngineThrows = false,
  List<DocumentMetadata>? documents,
}) {
  const tokenizer = DefaultTokenizer();
  const normalizer = DefaultTokenNormalizer();
  final stopWords = DefaultStopWordFilter();

  final indexRepository = _InMemoryIndexRepository();
  final indexCache = SearchIndexCache();
  final textEngine = _FakeTextEngine(throwOnOpen: textEngineThrows);
  final repository = _FakeSearchRepository(documents ?? [_metadata()]);

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

  return (
    engine: engine,
    indexRepository: indexRepository,
    textEngine: textEngine,
    repository: repository,
  );
}

void main() {
  group('KeywordSearchEngine indexing', () {
    test('an unindexed document is indexed on demand and matches', () async {
      final h = _build();
      expect(h.indexRepository.store, isEmpty,
          reason: 'precondition: nothing indexed yet');

      final results = await h.engine.search(const SearchQuery(keyword: 'budget'));

      expect(results, hasLength(1));
      expect(results.first.metadata.id, _kDocId);
      expect(results.first.score, greaterThan(0));
      expect(results.first.snippet, contains('budget'));
      expect(h.indexRepository.store.containsKey(_kDocId), isTrue,
          reason: 'the on-demand build must persist, not just match once');
    });

    test('the on-demand index is persisted, so it is built only once',
        () async {
      final h = _build();

      await h.engine.search(const SearchQuery(keyword: 'budget'));
      final savesAfterFirst = h.indexRepository.saveCount;

      await h.engine.search(const SearchQuery(keyword: 'procurement'));

      expect(savesAfterFirst, 1);
      expect(h.indexRepository.saveCount, 1,
          reason: 'second query must reuse the persisted index');
    });

    test('a pre-indexed document matches without rebuilding', () async {
      final h = _build();

      // Prime the store the way indexing-on-import would have.
      await h.engine.search(const SearchQuery(keyword: 'budget'));
      final opensAfterIndexing = h.textEngine.openCount;

      final results =
          await h.engine.search(const SearchQuery(keyword: 'infrastructure'));

      expect(results, hasLength(1));
      expect(h.indexRepository.saveCount, 1);
      // Snippet generation still opens the document; indexing does not re-run.
      expect(h.textEngine.openCount, greaterThan(opensAfterIndexing));
    });

    test('a document that cannot be parsed is skipped, not fatal', () async {
      final h = _build(textEngineThrows: true);

      final results = await h.engine.search(const SearchQuery(keyword: 'budget'));

      expect(results, isEmpty);
      expect(h.indexRepository.store, isEmpty);
    });

    test('a query with no matching term returns nothing', () async {
      final h = _build();

      final results =
          await h.engine.search(const SearchQuery(keyword: 'zebra'));

      expect(results, isEmpty);
      expect(h.indexRepository.store.containsKey(_kDocId), isTrue,
          reason: 'the document is still indexed, it just does not match');
    });

    test('an empty keyword returns candidates without snippets', () async {
      final h = _build();

      final results = await h.engine.search(const SearchQuery(keyword: ''));

      expect(results, hasLength(1));
      expect(results.first.snippet, isNull);
    });
  });

  // The defect this group covers: candidate selection filtered by
  // `file_name LIKE %keyword%`, so a term living only in a document's body
  // produced zero candidates and the engine returned before ever opening the
  // index. On device, `verification` (in the filename) returned a result while
  // `fox` and a body-only token returned nothing.
  group('content search', () {
    test('a term only in the body matches, with a snippet', () async {
      final h = _build();

      final results =
          await h.engine.search(const SearchQuery(keyword: 'procurement'));

      expect(results, hasLength(1),
          reason: 'body-only terms must reach the index');
      expect(results.first.metadata.id, _kDocId);
      expect(results.first.metadata.fileName, isNot(contains('procurement')),
          reason: 'precondition: the term is absent from the filename');
      expect(results.first.snippet, contains('procurement'));
      expect(results.first.matchPositions, isNotEmpty);
    });

    test('a term only in the filename matches as a title hit', () async {
      final h = _build();

      final results =
          await h.engine.search(const SearchQuery(keyword: 'notes'));

      expect(results, hasLength(1),
          reason: 'filename matching moved to the matcher, it is not lost');
      expect(_kContent.toLowerCase(), isNot(contains('notes')),
          reason: 'precondition: the term is absent from the body');
      expect(results.first.matchReason, contains('Title match'));
      expect(results.first.score, greaterThan(0));
    });

    test('candidates are fetched regardless of keyword, results are not',
        () async {
      final h = _build(documents: [_metadata(), _metadata2()]);

      final results = await h.engine.search(const SearchQuery(keyword: 'tern'));

      expect(h.repository.seenKeywords, ['tern'],
          reason: 'the keyword reaches the repository, which must ignore it');
      expect(h.indexRepository.store.keys, containsAll([_kDocId, _kDocId2]),
          reason: 'both documents were candidates, so both got indexed');
      expect(results, hasLength(1),
          reason: 'only the document whose body holds the term may match');
      expect(results.first.metadata.id, _kDocId2);
    });

    test('a body-only term is indexed on first search and reused on the second',
        () async {
      final h = _build();
      expect(h.indexRepository.store, isEmpty);

      final first =
          await h.engine.search(const SearchQuery(keyword: 'headcount'));
      expect(first, hasLength(1));
      expect(h.indexRepository.saveCount, 1,
          reason: 'first search builds the index on demand');

      final second =
          await h.engine.search(const SearchQuery(keyword: 'fiscal'));
      expect(second, hasLength(1));
      expect(h.indexRepository.saveCount, 1,
          reason: 'second search reuses the persisted index');
    });

    test('the workspace filter still excludes candidates', () async {
      final h = _build(documents: [_metadata(), _metadata2()]);

      final results = await h.engine.search(
        const SearchQuery(keyword: 'tern', workspaceId: _kWorkspaceId),
      );

      expect(results, isEmpty,
          reason: 'the only document holding the term is in another workspace');
      expect(h.indexRepository.store.containsKey(_kDocId2), isFalse,
          reason: 'an out-of-scope document must not even be indexed');
    });
  });
}
