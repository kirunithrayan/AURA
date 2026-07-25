import 'package:equatable/equatable.dart';
import 'search_query.dart';

abstract class SearchEvent extends Equatable {
  final String queryId;
  final DateTime timestamp;

  SearchEvent({
    required this.queryId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [queryId, timestamp];
}

class SearchStarted extends SearchEvent {
  final SearchQuery query;

  SearchStarted({
    required super.queryId,
    required this.query,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, query];
}

class SearchCompleted extends SearchEvent {
  final int resultCount;
  final Duration duration;
  final bool cacheHit;
  final String engineUsed;

  SearchCompleted({
    required super.queryId,
    required this.resultCount,
    required this.duration,
    required this.cacheHit,
    required this.engineUsed,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, resultCount, duration, cacheHit, engineUsed];
}

class SearchCancelled extends SearchEvent {
  SearchCancelled({
    required super.queryId,
    super.timestamp,
  });
}

class SearchFailed extends SearchEvent {
  final String error;

  SearchFailed({
    required super.queryId,
    required this.error,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, error];
}

class EngineStarted extends SearchEvent {
  final String engineId;

  EngineStarted({
    required super.queryId,
    required this.engineId,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, engineId];
}

class EngineCompleted extends SearchEvent {
  final String engineId;
  final int resultCount;
  final Duration duration;

  EngineCompleted({
    required super.queryId,
    required this.engineId,
    required this.resultCount,
    required this.duration,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, engineId, resultCount, duration];
}

class EngineSkipped extends SearchEvent {
  final String engineId;
  final String reason;

  EngineSkipped({
    required super.queryId,
    required this.engineId,
    required this.reason,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, engineId, reason];
}

class EngineFailed extends SearchEvent {
  final String engineId;
  final String error;

  EngineFailed({
    required super.queryId,
    required this.engineId,
    required this.error,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, engineId, error];
}

class MergeStarted extends SearchEvent {
  final int engineCount;

  MergeStarted({
    required super.queryId,
    required this.engineCount,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, engineCount];
}

class MergeCompleted extends SearchEvent {
  final int totalResultsBeforeMerge;
  final int finalResultCount;
  final Duration duration;

  MergeCompleted({
    required super.queryId,
    required this.totalResultsBeforeMerge,
    required this.finalResultCount,
    required this.duration,
    super.timestamp,
  });

  @override
  List<Object?> get props => [...super.props, totalResultsBeforeMerge, finalResultCount, duration];
}
