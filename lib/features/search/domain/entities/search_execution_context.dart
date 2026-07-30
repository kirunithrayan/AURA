import 'package:equatable/equatable.dart';
import 'search_query.dart';
import 'search_result.dart';
import 'search_engine_descriptor.dart';

class SearchExecutionContext extends Equatable {

  const SearchExecutionContext({
    required this.query,
    required this.activeEngines,
    this.mergedResults = const [],
    this.engineDurations = const {},
    this.duplicateCount = 0,
  });
  final SearchQuery query;
  final List<SearchEngineDescriptor> activeEngines;
  final List<SearchResult> mergedResults;
  final Map<String, Duration> engineDurations;
  final int duplicateCount;

  SearchExecutionContext copyWith({
    SearchQuery? query,
    List<SearchEngineDescriptor>? activeEngines,
    List<SearchResult>? mergedResults,
    Map<String, Duration>? engineDurations,
    int? duplicateCount,
  }) => SearchExecutionContext(
      query: query ?? this.query,
      activeEngines: activeEngines ?? this.activeEngines,
      mergedResults: mergedResults ?? this.mergedResults,
      engineDurations: engineDurations ?? this.engineDurations,
      duplicateCount: duplicateCount ?? this.duplicateCount,
    );

  @override
  List<Object?> get props => [
        query,
        activeEngines,
        mergedResults,
        engineDurations,
        duplicateCount,
      ];
}
