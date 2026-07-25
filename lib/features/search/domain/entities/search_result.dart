import 'package:equatable/equatable.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';

class SearchResult extends Equatable {
  final DocumentMetadata metadata;
  final double score;
  final String? snippet;
  final List<String> highlights;
  final List<int> matchPositions;
  final String? matchReason;
  final String searchEngineType;

  const SearchResult({
    required this.metadata,
    required this.score,
    this.snippet,
    this.highlights = const [],
    this.matchPositions = const [],
    this.matchReason,
    required this.searchEngineType,
  });

  SearchResult copyWith({
    DocumentMetadata? metadata,
    double? score,
    String? snippet,
    List<String>? highlights,
    List<int>? matchPositions,
    String? matchReason,
    String? searchEngineType,
  }) {
    return SearchResult(
      metadata: metadata ?? this.metadata,
      score: score ?? this.score,
      snippet: snippet ?? this.snippet,
      highlights: highlights ?? this.highlights,
      matchPositions: matchPositions ?? this.matchPositions,
      matchReason: matchReason ?? this.matchReason,
      searchEngineType: searchEngineType ?? this.searchEngineType,
    );
  }

  @override
  List<Object?> get props => [
        metadata,
        score,
        snippet,
        highlights,
        matchPositions,
        matchReason,
        searchEngineType,
      ];
}
