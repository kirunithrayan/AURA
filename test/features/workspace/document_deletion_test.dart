// Regression coverage for single-document deletion.
//
// The datasource's raw multi-table transaction is verified against real SQLite
// in document_deletion_datasource_test.dart. This suite exercises
// WorkspaceRepositoryImpl.removeFile against a controlled fake datasource plus
// REAL SearchIndexService, FileService and SearchCache instances, so the
// orchestration this repository owns — capture-before-delete, search-index
// cleanup, physical-file cleanup (filePath ONLY, never originalPath), cache
// invalidation, and failure handling — is proven against real collaborators.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/error/exceptions.dart';
import 'package:aura/features/workspace/data/datasources/workspace_local_datasource.dart';
import 'package:aura/features/workspace/data/models/workspace_file_model.dart';
import 'package:aura/features/workspace/data/models/workspace_model.dart';
import 'package:aura/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:aura/services/file_service.dart';
import 'package:aura/services/thumbnail_service.dart';

import 'package:aura/features/search/data/cache/search_cache.dart';
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
import 'package:aura/features/search/domain/entities/optimization/search_cache_configuration.dart';
import 'package:aura/features/search/domain/entities/optimization/search_cache_key.dart';
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

/// Stands in for the `workspaces`/`workspace_files` tables. Both the fake
/// datasource and the fake search candidate repository read from this same
/// map, so deleting through the datasource is what makes a document stop
/// being a search candidate — exactly how the real workspace_files-backed
/// SearchRepository behaves once the row is actually gone.
class _WorkspaceFilesStore {
  final Set<String> workspaceIds = {};
  final Map<String, WorkspaceFileModel> files = {};
}

class _FakeWorkspaceLocalDataSource implements WorkspaceLocalDataSource {
  _FakeWorkspaceLocalDataSource(this.store, {this.throwOnRemove = false});
  final _WorkspaceFilesStore store;
  final bool throwOnRemove;
  int removeCallCount = 0;

  @override
  Future<WorkspaceFileModel> getFileById(String fileId) async {
    final file = store.files[fileId];
    if (file == null) throw const NotFoundException('File not found');
    return file;
  }

  @override
  Future<void> removeFile(String id) async {
    removeCallCount++;
    if (throwOnRemove) {
      throw const DatabaseException('Failed to remove file: simulated failure');
    }
    store.files.remove(id);
  }

  @override
  Future<List<WorkspaceFileModel>> getWorkspaceFiles(String workspaceId) async =>
      store.files.values.where((f) => f.workspaceId == workspaceId).toList();

  @override
  Future<void> deleteWorkspace(String id) async {
    store.workspaceIds.remove(id);
    store.files.removeWhere((_, f) => f.workspaceId == id);
  }

  @override
  Future<List<WorkspaceModel>> getWorkspaces() => throw UnimplementedError();
  @override
  Future<WorkspaceModel> getWorkspaceById(String id) => throw UnimplementedError();
  @override
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) => throw UnimplementedError();
  @override
  Future<WorkspaceModel> updateWorkspace(WorkspaceModel workspace) => throw UnimplementedError();
  @override
  Future<WorkspaceFileModel> addFile(WorkspaceFileModel file) => throw UnimplementedError();
  @override
  Future<void> updateFileViewerState(String fileId,
          {int? lastOpenedAt, int? lastViewedPage, double? lastZoomLevel, double? lastScrollPosition}) =>
      throw UnimplementedError();
  @override
  Future<List<WorkspaceFileModel>> getPinnedDocuments(String workspaceId) => throw UnimplementedError();
  @override
  Future<void> pinDocument(String fileId, String workspaceId) => throw UnimplementedError();
  @override
  Future<void> unpinDocument(String fileId, String workspaceId) => throw UnimplementedError();
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository(this.store);
  final _WorkspaceFilesStore store;

  @override
  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async {
    final scoped = query.workspaceId == null
        ? store.files.values
        : store.files.values.where((f) => f.workspaceId == query.workspaceId);
    return scoped
        .map((f) => DocumentMetadata(
              id: f.id,
              workspaceId: f.workspaceId,
              fileName: f.fileName,
              fileExtension: f.extension,
              filePath: f.filePath,
              createdAt: f.createdAt,
              modifiedAt: f.modifiedAt,
              importedAt: f.importedAt,
            ))
        .take(query.limit)
        .toList();
  }
}

class _FakeTextEngine implements AbstractTextDocumentEngine {
  _FakeTextEngine(this.contentById);
  final Map<String, String> contentById;

  @override
  Future<TextDocument> openDocument(WorkspaceFile file) async {
    final content = contentById[file.id] ?? '';
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
  ViewerSearchResult search(String keyword) => throw UnimplementedError();
}

class _InMemoryIndexRepository implements SearchIndexRepository {
  final Map<String, SearchIndex> store = {};

  @override
  Future<void> saveIndex(SearchIndex index) async => store[index.documentId] = index;
  @override
  Future<SearchIndex?> getIndex(String documentId) async => store[documentId];
  @override
  Future<void> deleteIndex(String documentId) async => store.remove(documentId);
  @override
  Future<({String? checksum, String? parserVersion})?> getIndexMeta(String documentId) async {
    final index = store[documentId];
    if (index == null) return null;
    return (checksum: index.checksum, parserVersion: index.parserVersion);
  }

  @override
  Future<List<String>> getIndexedDocumentIds(String workspaceId) async => store.keys.toList();
}

class _SilentLogger implements SearchLogger {
  @override
  Future<void> logSearch(SearchQuery query, SearchStatistics stats) async {}
  @override
  Future<void> logFailure(SearchQuery query, String error) async {}
  @override
  Future<void> logCacheEvent(String queryId, String cacheKey, bool hit) async {}
  @override
  Future<void> logOptimization(String type, Duration duration, Map<String, dynamic> meta) async {}
  @override
  Future<void> logBatchEvent(String jobId, String status, {int? processed, int? failed, String? error}) async {}
  @override
  Future<void> logWithContext(SearchLogContext context, {Map<String, dynamic>? extraData, String? errorMessage}) async {}
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

WorkspaceFileModel _file({
  required String id,
  required String workspaceId,
  required String filePath,
  String? originalPath,
  String fileName = 'doc.txt',
}) =>
    WorkspaceFileModel(
      id: id,
      workspaceId: workspaceId,
      fileName: fileName,
      filePath: filePath,
      originalPath: originalPath,
      extension: 'txt',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('aura_document_delete_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  ({
    WorkspaceRepositoryImpl repository,
    _WorkspaceFilesStore store,
    _FakeWorkspaceLocalDataSource dataSource,
    SearchIndexService indexService,
    _InMemoryIndexRepository indexRepository,
    KeywordSearchEngine searchEngine,
    SearchCache searchCache,
  }) build({
    bool throwOnRemove = false,
    Map<String, String> contentById = const {},
  }) {
    final store = _WorkspaceFilesStore();
    final dataSource = _FakeWorkspaceLocalDataSource(store, throwOnRemove: throwOnRemove);

    const tokenizer = DefaultTokenizer();
    const normalizer = DefaultTokenNormalizer();
    final stopWords = DefaultStopWordFilter();
    final indexRepository = _InMemoryIndexRepository();
    final indexCache = SearchIndexCache();
    final textEngine = _FakeTextEngine(contentById);

    final indexService = SearchIndexService(
      textEngine,
      DefaultIndexBuilder(tokenizer, normalizer, stopWords),
      indexRepository,
      indexCache,
      _SilentEventBus(),
      _SilentIndexLogger(),
    );

    final searchRepository = _FakeSearchRepository(store);
    final searchEngine = KeywordSearchEngine(
      searchRepository,
      indexRepository,
      indexCache,
      DefaultQueryProcessor(tokenizer, normalizer, stopWords),
      const DefaultMatchingStrategy(),
      const SearchSnippetGenerator(),
      textEngine,
      _SilentLogger(),
      indexService,
    );

    final searchCache = SearchCache(const SearchCacheConfiguration());

    final repository = WorkspaceRepositoryImpl(
      localDataSource: dataSource,
      fileService: FileService(),
      thumbnailService: ThumbnailService(),
      searchIndexService: indexService,
      searchCache: searchCache,
    );

    return (
      repository: repository,
      store: store,
      dataSource: dataSource,
      indexService: indexService,
      indexRepository: indexRepository,
      searchEngine: searchEngine,
      searchCache: searchCache,
    );
  }

  Future<File> writeTempFile(Directory dir, String name, String content) async {
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    return file;
  }

  test('removeFile removes the associated search index', () async {
    final h = build(contentById: {'file-A': 'budget infrastructure planning'});
    h.store.workspaceIds.add('ws-A');
    final path = (await writeTempFile(tempDir, 'a.txt', 'x')).path;
    h.store.files['file-A'] = _file(id: 'file-A', workspaceId: 'ws-A', filePath: path);

    // Build a real index the way lazy indexing would.
    await h.searchEngine.search(const SearchQuery(keyword: 'budget'));
    expect(await h.indexRepository.getIndex('file-A'), isNotNull,
        reason: 'precondition: the document is indexed before deletion');

    final result = await h.repository.removeFile('file-A');

    expect(result.isRight(), isTrue);
    expect(await h.indexRepository.getIndex('file-A'), isNull,
        reason: 'removeFile must call searchIndexService.removeIndex(fileId)');
  });

  test('removeFile deletes the AURA-owned filePath, NOT originalPath', () async {
    final h = build();
    h.store.workspaceIds.add('ws-A');
    final owned = await writeTempFile(tempDir, 'owned.txt', 'content'); // filePath
    final source = await writeTempFile(tempDir, 'source.txt', 'content'); // originalPath
    h.store.files['file-A'] = _file(
      id: 'file-A',
      workspaceId: 'ws-A',
      filePath: owned.path,
      originalPath: source.path,
    );
    expect(await owned.exists(), isTrue, reason: 'precondition');
    expect(await source.exists(), isTrue, reason: 'precondition');

    final result = await h.repository.removeFile('file-A');

    expect(result.isRight(), isTrue);
    expect(await owned.exists(), isFalse, reason: 'the AURA-owned filePath copy must be deleted');
    expect(await source.exists(), isTrue,
        reason: "the user's originalPath source file must NEVER be deleted");
  });

  test('removeFile invalidates the search cache', () async {
    final h = build();
    h.store.workspaceIds.add('ws-A');
    h.store.files['file-A'] =
        _file(id: 'file-A', workspaceId: 'ws-A', filePath: (await writeTempFile(tempDir, 'a.txt', 'x')).path);

    h.searchCache.put(
      const SearchCacheKey(normalizedKeyword: 'x', filterHash: 'y', offset: 0, limit: 20),
      const [],
    );
    expect(h.searchCache.getStatistics().currentSize, 1, reason: 'precondition');

    await h.repository.removeFile('file-A');

    expect(h.searchCache.getStatistics().currentSize, 0,
        reason: 'a stale cached result set must not survive a document deletion');
  });

  test('a missing physical file does not fail the delete', () async {
    final h = build();
    h.store.workspaceIds.add('ws-A');
    h.store.files['file-A'] = _file(
      id: 'file-A',
      workspaceId: 'ws-A',
      filePath: '${tempDir.path}/never-existed.txt',
    );

    final result = await h.repository.removeFile('file-A');

    expect(result.isRight(), isTrue,
        reason: 'a missing physical file is post-commit hygiene, not a deletion failure');
  });

  test('a DB failure returns Failure and does NOT clean index/file/cache', () async {
    final h = build(throwOnRemove: true, contentById: {'file-A': 'budget'});
    h.store.workspaceIds.add('ws-A');
    final file = await writeTempFile(tempDir, 'a.txt', 'x');
    h.store.files['file-A'] = _file(id: 'file-A', workspaceId: 'ws-A', filePath: file.path);
    await h.searchEngine.search(const SearchQuery(keyword: 'budget'));
    expect(await h.indexRepository.getIndex('file-A'), isNotNull, reason: 'precondition');
    h.searchCache.put(
      const SearchCacheKey(normalizedKeyword: 'x', filterHash: 'y', offset: 0, limit: 20),
      const [],
    );

    final result = await h.repository.removeFile('file-A');

    expect(result.isLeft(), isTrue, reason: 'a DB failure must never be reported as success');
    expect(h.dataSource.removeCallCount, 1);
    // Nothing downstream of the failed transaction should have run.
    expect(await file.exists(), isTrue, reason: 'physical file must survive a DB failure');
    expect(await h.indexRepository.getIndex('file-A'), isNotNull,
        reason: 'search index must survive a DB failure (removeIndex not called)');
    expect(h.searchCache.getStatistics().currentSize, 1,
        reason: 'cache must not be invalidated when the DB delete failed');
  });
}
