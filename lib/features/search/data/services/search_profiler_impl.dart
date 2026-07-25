import 'dart:async';
import '../../domain/entities/optimization/search_profile.dart';
import '../../domain/services/search_profiler.dart';
import '../../domain/repositories/search_event_bus.dart';
import '../../domain/entities/search_event.dart';

class SearchProfilerImpl implements SearchProfiler {
  final SearchEventBus _eventBus;
  StreamSubscription? _subscription;
  
  final Map<String, _QueryProfileBuilder> _builders = {};

  SearchProfilerImpl(this._eventBus) {
    _subscription = _eventBus.events.listen(_onEvent);
  }

  void _onEvent(SearchEvent event) {
    if (event is SearchStarted) {
      _builders[event.queryId] = _QueryProfileBuilder(event.queryId);
    } else if (event is EngineCompleted) {
      final builder = _builders[event.queryId];
      if (builder != null) {
        builder.engineExecutionDuration += event.duration;
      }
    } else if (event is MergeCompleted) {
      final builder = _builders[event.queryId];
      if (builder != null) {
        builder.filteringDuration += event.duration; // Roughly
      }
    } else if (event is SearchCompleted) {
      final builder = _builders[event.queryId];
      if (builder != null) {
        builder.totalPipelineDuration = event.duration;
      }
    }
  }

  @override
  SearchProfile? getProfile(String queryId) {
    final builder = _builders[queryId];
    if (builder == null) return null;
    return builder.build();
  }

  @override
  void clear() {
    _builders.clear();
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class _QueryProfileBuilder {
  final String queryId;
  Duration engineExecutionDuration = Duration.zero;
  Duration filteringDuration = Duration.zero;
  Duration rankingDuration = Duration.zero;
  Duration postProcessingDuration = Duration.zero;
  Duration totalPipelineDuration = Duration.zero;

  _QueryProfileBuilder(this.queryId);

  SearchProfile build() {
    return SearchProfile(
      queryId: queryId,
      engineExecutionDuration: engineExecutionDuration,
      filteringDuration: filteringDuration,
      rankingDuration: rankingDuration,
      postProcessingDuration: postProcessingDuration,
      totalPipelineDuration: totalPipelineDuration,
    );
  }
}
