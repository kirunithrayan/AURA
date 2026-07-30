import 'package:equatable/equatable.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';
import 'search_explanation.dart';

class SearchResult extends Equatable { // Added for RAG Context Building

  const SearchResult({
    required this.metadata,
    required this.score,
    this.snippet,
    this.highlights = const [],
    this.matchPositions = const [],
    this.matchReason,
    this.explanation,
    required this.searchEngineType,
    this.chunkIndex,
  });
  final DocumentMetadata metadata;
  final double score;
  final String? snippet;
  final List<String> highlights;
  final List<int> matchPositions;
  final String? matchReason;
  final SearchExplanation? explanation;
  final String searchEngineType;
  final int? chunkIndex;

  SearchResult copyWith({
    DocumentMetadata? metadata,
    double? score,
    String? snippet,
    List<String>? highlights,
    List<int>? matchPositions,
    String? matchReason,
    SearchExplanation? explanation,
    String? searchEngineType,
    int? chunkIndex,
  }) => SearchResult(
      metadata: metadata ?? this.metadata,
      score: score ?? this.score,
      snippet: snippet ?? this.snippet,
      highlights: highlights ?? this.highlights,
      matchPositions: matchPositions ?? this.matchPositions,
      matchReason: matchReason ?? this.matchReason,
      explanation: explanation ?? this.explanation,
      searchEngineType: searchEngineType ?? this.searchEngineType,
      chunkIndex: chunkIndex ?? this.chunkIndex,
    );

  @override
  List<Object?> get props => [
        metadata,
        score,
        snippet,
        highlights,
        matchPositions,
        matchReason,
        explanation,
        searchEngineType,
        chunkIndex,
      ];
}
