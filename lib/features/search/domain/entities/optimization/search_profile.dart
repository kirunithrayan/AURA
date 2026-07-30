import 'package:equatable/equatable.dart';

class SearchProfile extends Equatable {

  const SearchProfile({
    required this.queryId,
    required this.engineExecutionDuration,
    required this.filteringDuration,
    required this.rankingDuration,
    required this.postProcessingDuration,
    required this.totalPipelineDuration,
  });
  final String queryId;
  final Duration engineExecutionDuration;
  final Duration filteringDuration;
  final Duration rankingDuration;
  final Duration postProcessingDuration;
  final Duration totalPipelineDuration;

  @override
  List<Object?> get props => [
        queryId,
        engineExecutionDuration,
        filteringDuration,
        rankingDuration,
        postProcessingDuration,
        totalPipelineDuration,
      ];
}
