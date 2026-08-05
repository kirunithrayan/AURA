// Wire 1 (indexing on import) calls BatchIndexingService.enqueueBatch with the
// files that were just imported. These tests cover that contract: given files,
// the service must actually persist an index for each one.
//
// The call site itself — WorkspaceDetailViewModel.importFiles — is not covered
// here because ImportFile type-checks its repository against the concrete
// WorkspaceRepositoryImpl, so a faked repository never reaches the success
// path. Search correctness does not depend on that call regardless:
// KeywordSearchEngine indexes on demand, covered in
// keyword_search_indexing_test.dart.

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/search/data/indexing/batch_indexing_service_impl.dart';
import 'package:aura/features/search/data/indexing/search_index_service.dart';
import 'package:aura/features/search/data/indexing/search_index_logger.dart';
import 'package:aura/features/search/data/indexing/cache/search_index_cache.dart';
import 'package:aura/features/search/data/indexing/repositories/search_index_repository.dart';
import 'package:aura/features/search/data/indexing/builder/default_index_builder.dart';
import 'package:aura/features/search/data/indexing/tokenizer/default_tokenizer.dart';
import 'package:aura/features/search/data/indexing/normalizer/default_token_normalizer.dart';
import 'package:aura/features/search/data/indexing/filter/default_stop_word_filter.dart';
import 'package:aura/features/search/domain/entities/indexing/search_index.dart';
import 'package:aura/features/search/domain/entities/indexing/search_index_statistics.dart';
import 'package:aura/features/search/domain/entities/optimization/batch_index_job.dart';
import 'package:aura/features/search/domain/entities/search_event.dart';
import 'package:aura/features/search/domain/entities/search_query.dart';
import 'package:aura/features/search/domain/entities/search_statistics.dart';
import 'package:aura/features/search/domain/entities/search_log_context.dart';
import 'package:aura/features/search/domain/repositories/search_event_bus.dart';
import 'package:aura/features/search/domain/repositories/search_logger.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:aura/features/document_viewer/domain/entities/viewer_search_result.dart';
import 'package:aura/core/text_engine/abstract_text_document_engine.dart';
import 'package:aura/core/text_engine/models/text_document.dart';

WorkspaceFile _file(String id) => WorkspaceFile(
      id: id,
      workspaceId: 'ws-1',
      fileName: '$id.txt',
      filePath: '/tmp/$id.txt',
      extension: 'txt',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

class _InMemoryIndexRepository implements SearchIndexRepository {
  final Map<String, SearchIndex> store = {};

  @override
  Future<void> saveIndex(SearchIndex index) async =>
      store[index.documentId] = index;

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
  _FakeTextEngine({this.failFor = const {}});

  final Set<String> failFor;

  @override
  Future<TextDocument> openDocument(WorkspaceFile file) async {
    if (failFor.contains(file.id)) {
      throw StateError('cannot parse ${file.id}');
    }
    return TextDocument(
      title: file.fileName,
      content: 'quarterly budget notes for ${file.id}',
      headings: const [],
      paragraphCount: 1,
      wordCount: 6,
      characterCount: 40,
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
  ViewerSearchResult search(String keyword) => throw UnimplementedError();
}

class _SilentIndexLogger implements SearchIndexLogger {
  @override
  void logIndexed(String documentId, SearchIndexStatistics stats) {}
  @override
  void logSkipped(String documentId, String reason) {}
  @override
  void logFailure(String documentId, String error) {}
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

class _SilentEventBus implements SearchEventBus {
  @override
  void publish(SearchEvent event) {}
  @override
  Stream<SearchEvent> get events => const Stream.empty();
}

({BatchIndexingServiceImpl service, _InMemoryIndexRepository repository})
    _build({Set<String> unparseable = const {}}) {
  const tokenizer = DefaultTokenizer();
  const normalizer = DefaultTokenNormalizer();
  final stopWords = DefaultStopWordFilter();
  final repository = _InMemoryIndexRepository();

  final indexService = SearchIndexService(
    _FakeTextEngine(failFor: unparseable),
    DefaultIndexBuilder(tokenizer, normalizer, stopWords),
    repository,
    SearchIndexCache(),
    _SilentEventBus(),
    _SilentIndexLogger(),
  );

  return (
    service: BatchIndexingServiceImpl(
      indexService,
      _SilentEventBus(),
      _SilentLogger(),
    ),
    repository: repository,
  );
}

/// enqueueBatch dispatches with `unawaited`, so the job finishes after the
/// returned future. Poll until it settles.
Future<BatchIndexJob> _awaitJob(
    BatchIndexingServiceImpl service, String jobId) async {
  for (var i = 0; i < 200; i++) {
    final job = await service.getJobStatus(jobId);
    if (job != null &&
        (job.status == BatchJobStatus.completed ||
            job.status == BatchJobStatus.failed)) {
      return job;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('batch job $jobId never settled');
}

void main() {
  group('BatchIndexingService', () {
    test('indexes every file it is given', () async {
      final h = _build();

      final jobId = await h.service
          .enqueueBatch([_file('doc-1'), _file('doc-2'), _file('doc-3')]);
      final job = await _awaitJob(h.service, jobId);

      expect(job.status, BatchJobStatus.completed);
      expect(job.processedCount, 3);
      expect(job.failedCount, 0);
      expect(h.repository.store.keys,
          containsAll(<String>['doc-1', 'doc-2', 'doc-3']));
    });

    test('the persisted index has entries that can be matched', () async {
      final h = _build();

      final jobId = await h.service.enqueueBatch([_file('doc-1')]);
      await _awaitJob(h.service, jobId);

      final index = h.repository.store['doc-1']!;
      expect(index.entries, isNotEmpty);
      expect(
        index.entries.map((e) => e.normalizedToken),
        contains('budget'),
      );
    });

    test('one unparseable file does not abort the rest of the batch',
        () async {
      final h = _build(unparseable: {'doc-2'});

      final jobId = await h.service
          .enqueueBatch([_file('doc-1'), _file('doc-2'), _file('doc-3')]);
      final job = await _awaitJob(h.service, jobId);

      expect(job.status, BatchJobStatus.completed);
      expect(h.repository.store.keys, containsAll(<String>['doc-1', 'doc-3']));
      expect(h.repository.store.containsKey('doc-2'), isFalse,
          reason: 'the unparseable file must not get a bogus index');

      // indexDocument rethrows, so BatchIndexingServiceImpl's per-file catch
      // fires and the counters tell the truth: two indexed, one failed. Before
      // that fix indexDocument swallowed its own failures and returned null,
      // which pinned failedCount at 0 and let a batch where every single write
      // failed still report full success.
      expect(job.processedCount, 2);
      expect(job.failedCount, 1);
    });

    test('an empty batch completes without work', () async {
      final h = _build();

      final jobId = await h.service.enqueueBatch([]);
      final job = await _awaitJob(h.service, jobId);

      expect(job.status, BatchJobStatus.completed);
      expect(job.processedCount, 0);
      expect(h.repository.store, isEmpty);
    });
  });
}
