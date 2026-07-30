import 'package:equatable/equatable.dart';
import 'search_query.dart';

abstract class SearchEvent extends Equatable {

  SearchEvent({
    required this.queryId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  final String queryId;
  final DateTime timestamp;

  @override
  List<Object?> get props => [queryId, timestamp];
}

class SearchStarted extends SearchEvent {

  SearchStarted({
    required super.queryId,
    required this.query,
    super.timestamp,
  });
  final SearchQuery query;

  @override
  List<Object?> get props => [...super.props, query];
}

class SearchCompleted extends SearchEvent {

  SearchCompleted({
    required super.queryId,
    required this.resultCount,
    required this.duration,
    required this.cacheHit,
    required this.engineUsed,
    super.timestamp,
  });
  final int resultCount;
  final Duration duration;
  final bool cacheHit;
  final String engineUsed;

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

  SearchFailed({
    required super.queryId,
    required this.error,
    super.timestamp,
  });
  final String error;

  @override
  List<Object?> get props => [...super.props, error];
}

class EngineStarted extends SearchEvent {

  EngineStarted({
    required super.queryId,
    required this.engineId,
    super.timestamp,
  });
  final String engineId;

  @override
  List<Object?> get props => [...super.props, engineId];
}

class EngineCompleted extends SearchEvent {

  EngineCompleted({
    required super.queryId,
    required this.engineId,
    required this.resultCount,
    required this.duration,
    super.timestamp,
  });
  final String engineId;
  final int resultCount;
  final Duration duration;

  @override
  List<Object?> get props => [...super.props, engineId, resultCount, duration];
}

class EngineSkipped extends SearchEvent {

  EngineSkipped({
    required super.queryId,
    required this.engineId,
    required this.reason,
    super.timestamp,
  });
  final String engineId;
  final String reason;

  @override
  List<Object?> get props => [...super.props, engineId, reason];
}

class EngineFailed extends SearchEvent {

  EngineFailed({
    required super.queryId,
    required this.engineId,
    required this.error,
    super.timestamp,
  });
  final String engineId;
  final String error;

  @override
  List<Object?> get props => [...super.props, engineId, error];
}

class MergeStarted extends SearchEvent {

  MergeStarted({
    required super.queryId,
    required this.engineCount,
    super.timestamp,
  });
  final int engineCount;

  @override
  List<Object?> get props => [...super.props, engineCount];
}

class MergeCompleted extends SearchEvent {

  MergeCompleted({
    required super.queryId,
    required this.totalResultsBeforeMerge,
    required this.finalResultCount,
    required this.duration,
    super.timestamp,
  });
  final int totalResultsBeforeMerge;
  final int finalResultCount;
  final Duration duration;

  @override
  List<Object?> get props => [...super.props, totalResultsBeforeMerge, finalResultCount, duration];
}

class BatchIndexStarted extends SearchEvent {

  BatchIndexStarted({
    required super.queryId,
    required this.documentCount,
    super.timestamp,
  });
  final int documentCount;

  @override
  List<Object?> get props => [...super.props, documentCount];
}

class BatchIndexCompleted extends SearchEvent {

  BatchIndexCompleted({
    required super.queryId,
    required this.processedCount,
    required this.failedCount,
    super.timestamp,
  });
  final int processedCount;
  final int failedCount;

  @override
  List<Object?> get props => [...super.props, processedCount, failedCount];
}

class BatchIndexFailed extends SearchEvent {

  BatchIndexFailed({
    required super.queryId,
    required this.error,
    super.timestamp,
  });
  final String error;

  @override
  List<Object?> get props => [...super.props, error];
}

class CacheHit extends SearchEvent {
  CacheHit({required super.queryId, this.cacheKey, super.timestamp});
  final String? cacheKey;
}

class CacheMiss extends SearchEvent {
  CacheMiss({required super.queryId, this.cacheKey, super.timestamp});
  final String? cacheKey;
}
