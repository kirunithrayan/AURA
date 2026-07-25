import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/text_engine/abstract_text_document_engine.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../../domain/entities/indexing/search_index.dart';
import '../../domain/entities/indexing/search_index_event.dart';
import '../../domain/repositories/search_event_bus.dart';
import 'builder/abstract_index_builder.dart';
import 'cache/search_index_cache.dart';
import 'repositories/search_index_repository.dart';
import 'search_index_logger.dart';
import 'package:uuid/uuid.dart';

/// Service orchestrating all indexing operations.
///
/// Provides: index, update, remove, rebuild.
/// Uses change-detection (checksum + parserVersion) to skip unnecessary work.
/// Designed so the same pipeline can later run in isolates or WorkManager.
class SearchIndexService {
  final AbstractTextDocumentEngine _textEngine;
  final AbstractIndexBuilder _indexBuilder;
  final SearchIndexRepository _indexRepository;
  final SearchIndexCache _indexCache;
  final SearchEventBus _eventBus;
  final SearchIndexLogger _logger;

  SearchIndexService(
    this._textEngine,
    this._indexBuilder,
    this._indexRepository,
    this._indexCache,
    this._eventBus,
    this._logger,
  );

  /// Indexes a document. Skips if the checksum and parser version haven't changed.
  Future<SearchIndex?> indexDocument(WorkspaceFile file) async {
    final eventId = const Uuid().v4();

    _eventBus.publish(IndexStarted(documentId: file.id, queryId: eventId));

    try {
      // 1. Check timestamp first (fastest check)
      final existingMeta = await _indexRepository.getIndexMeta(file.id);
      
      if (existingMeta != null) {
        final modifiedTime = DateTime.fromMillisecondsSinceEpoch(file.modifiedAt);
        // If the index is newer than the file's last modified time, we might be able to skip
        if (existingMeta.indexedAt.isAfter(modifiedTime)) {
          // Verify parser version too, just in case parsers were upgraded
          if (existingMeta.parserVersion == _indexBuilder.parserVersion) {
            _eventBus.publish(IndexSkipped(
              documentId: file.id,
              queryId: eventId,
              reason: 'File unmodified since last index',
            ));
            _logger.logSkipped(file.id, 'File unmodified since last index');
            return _indexCache.get(file.id) ?? await _indexRepository.getIndex(file.id);
          }
        }
      }

      // 2. Parse document via shared TextEngine
      final textDoc = await _textEngine.openDocument(file);

      // 3. Compute checksum of content for strict change detection
      final contentChecksum = _computeChecksum(textDoc.content);
      final currentParserVersion = textDoc.parserVersion ?? 'unknown';

      // 4. Strict Checksum & Version Check
      if (existingMeta != null &&
          existingMeta.checksum == contentChecksum &&
          existingMeta.parserVersion == currentParserVersion) {
        _eventBus.publish(IndexSkipped(
          documentId: file.id,
          queryId: eventId,
          reason: 'Checksum and parser version unchanged',
        ));
        _logger.logSkipped(file.id, 'Checksum and parser version unchanged');

        // Return cached or persisted index
        return _indexCache.get(file.id) ?? await _indexRepository.getIndex(file.id);
      }

      // 4. Build index
      final result = _indexBuilder.build(
        documentId: file.id,
        workspaceId: file.workspaceId,
        documentType: file.extension ?? 'unknown',
        content: textDoc.content,
        title: textDoc.title,
        checksum: contentChecksum,
        parserVersion: currentParserVersion,
      );

      // 5. Persist
      await _indexRepository.saveIndex(result.index);

      // 6. Cache
      _indexCache.put(file.id, result.index);

      // 7. Publish and log
      _eventBus.publish(IndexCompleted(
        documentId: file.id,
        queryId: eventId,
        statistics: result.statistics,
      ));
      _logger.logIndexed(file.id, result.statistics);

      return result.index;
    } catch (e) {
      _eventBus.publish(IndexFailed(
        documentId: file.id,
        queryId: eventId,
        error: e.toString(),
      ));
      _logger.logFailure(file.id, e.toString());
      return null;
    }
  }

  /// Force re-indexes a document regardless of change detection.
  Future<SearchIndex?> rebuildIndex(WorkspaceFile file) async {
    _indexCache.remove(file.id);
    await _indexRepository.deleteIndex(file.id);
    return indexDocument(file);
  }

  /// Removes an index for a given document.
  Future<void> removeIndex(String documentId) async {
    _indexCache.remove(documentId);
    await _indexRepository.deleteIndex(documentId);
  }

  /// Retrieves a cached or persisted index for a document.
  Future<SearchIndex?> getIndex(String documentId) async {
    final cached = _indexCache.get(documentId);
    if (cached != null) return cached;

    final persisted = await _indexRepository.getIndex(documentId);
    if (persisted != null) {
      _indexCache.put(documentId, persisted);
    }
    return persisted;
  }

  String _computeChecksum(String content) {
    return sha256.convert(utf8.encode(content)).toString();
  }
}
