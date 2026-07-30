import '../../../../../core/utils/app_logger.dart';
import '../../domain/entities/indexing/search_index_statistics.dart';

/// Abstraction for logging indexing operations.
abstract class SearchIndexLogger {
  void logIndexed(String documentId, SearchIndexStatistics stats);
  void logSkipped(String documentId, String reason);
  void logFailure(String documentId, String error);
}

/// Default implementation that writes to AppLogger.
class SearchIndexLoggerImpl implements SearchIndexLogger {
  const SearchIndexLoggerImpl();

  @override
  void logIndexed(String documentId, SearchIndexStatistics stats) {
    AppLogger.info(
      'IndexCompleted | DocId: $documentId | '
      'Tokens: ${stats.tokenCount} | '
      'Unique: ${stats.uniqueTokenCount} | '
      'Duration: ${stats.indexingDuration.inMilliseconds}ms | '
      'Size: ${stats.documentSize}B',
    );
  }

  @override
  void logSkipped(String documentId, String reason) {
    AppLogger.info('IndexSkipped | DocId: $documentId | Reason: $reason');
  }

  @override
  void logFailure(String documentId, String error) {
    AppLogger.error('IndexFailed | DocId: $documentId', error);
  }
}
