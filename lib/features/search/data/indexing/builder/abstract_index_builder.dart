import '../../../domain/entities/indexing/search_index.dart';
import '../../../domain/entities/indexing/search_index_statistics.dart';

/// Contract for building a SearchIndex from a parsed document.
abstract class AbstractIndexBuilder {
  /// Builds a complete search index for the given document content.
  /// Returns a record containing both the built index and its statistics.
  ({SearchIndex index, SearchIndexStatistics statistics}) build({
    required String documentId,
    required String workspaceId,
    required String documentType,
    required String content,
    required String title,
    required String checksum,
    required String parserVersion,
  });
}
