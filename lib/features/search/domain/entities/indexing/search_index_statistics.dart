import 'package:equatable/equatable.dart';

/// Statistics about a single indexing operation.
class SearchIndexStatistics extends Equatable {

  const SearchIndexStatistics({
    required this.tokenCount,
    required this.uniqueTokenCount,
    required this.indexingDuration,
    required this.documentSize,
  });
  final int tokenCount;
  final int uniqueTokenCount;
  final Duration indexingDuration;
  final int documentSize;

  @override
  List<Object?> get props => [tokenCount, uniqueTokenCount, indexingDuration, documentSize];
}
