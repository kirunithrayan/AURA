class SearchLogContext {

  SearchLogContext({
    required this.operation,
    this.duration,
    required this.success,
    this.workspaceId,
    this.queryHash,
    this.searchEngine,
    this.cacheHit,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  final String operation;
  final Duration? duration;
  final bool success;
  final String? workspaceId;
  final String? queryHash;
  final String? searchEngine;
  final bool? cacheHit;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
      'operation': operation,
      if (duration != null) 'duration_ms': duration!.inMilliseconds,
      'success': success,
      if (workspaceId != null) 'workspaceId': workspaceId,
      if (queryHash != null) 'queryHash': queryHash,
      if (searchEngine != null) 'searchEngine': searchEngine,
      if (cacheHit != null) 'cacheHit': cacheHit,
      'timestamp': timestamp.toIso8601String(),
    };
}
