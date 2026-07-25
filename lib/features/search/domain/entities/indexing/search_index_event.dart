import 'package:equatable/equatable.dart';
import '../search_event.dart';
import 'search_index_statistics.dart';

/// Base class for all search indexing events.
/// Extends the SearchEvent hierarchy so the same SearchEventBus can publish both.
abstract class SearchIndexEvent extends SearchEvent {
  final String documentId;

  SearchIndexEvent({
    required this.documentId,
    required super.queryId,
    super.timestamp,
  });

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
  final SearchIndexStatistics statistics;

  IndexCompleted({
    required super.documentId,
    required super.queryId,
    required this.statistics,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, statistics];
}

class IndexSkipped extends SearchIndexEvent {
  final String reason;

  IndexSkipped({
    required super.documentId,
    required super.queryId,
    required this.reason,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, reason];
}

class IndexFailed extends SearchIndexEvent {
  final String error;

  IndexFailed({
    required super.documentId,
    required super.queryId,
    required this.error,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, error];
}
