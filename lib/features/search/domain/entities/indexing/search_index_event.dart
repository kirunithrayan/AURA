import '../search_event.dart';
import 'search_index_statistics.dart';

/// Base class for all search indexing events.
/// Extends the SearchEvent hierarchy so the same SearchEventBus can publish both.
abstract class SearchIndexEvent extends SearchEvent {

  SearchIndexEvent({
    required this.documentId,
    required super.queryId,
    super.timestamp,
  });
  final String documentId;

  @override
  List<Object?> get props => [...super.props, documentId];
}

class IndexStarted extends SearchIndexEvent {
  IndexStarted({
    required super.documentId,
    required super.queryId,
    super.timestamp,
  });
}

class IndexCompleted extends SearchIndexEvent {

  IndexCompleted({
    required super.documentId,
    required super.queryId,
    required this.statistics,
    super.timestamp,
  });
  final SearchIndexStatistics statistics;

  @override
  List<Object?> get props => [...super.props, statistics];
}

class IndexSkipped extends SearchIndexEvent {

  IndexSkipped({
    required super.documentId,
    required super.queryId,
    required this.reason,
    super.timestamp,
  });
  final String reason;

  @override
  List<Object?> get props => [...super.props, reason];
}

class IndexFailed extends SearchIndexEvent {

  IndexFailed({
    required super.documentId,
    required super.queryId,
    required this.error,
    super.timestamp,
  });
  final String error;

  @override
  List<Object?> get props => [...super.props, error];
}
