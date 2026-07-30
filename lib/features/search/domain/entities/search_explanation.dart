import 'package:equatable/equatable.dart';

/// Encapsulates semantic score, keyword score, matched snippet, and explanation for search results.
class SearchExplanation extends Equatable {

  const SearchExplanation({
    this.semanticScore,
    this.keywordScore,
    this.matchedSnippet,
    required this.explanation,
  });
  final double? semanticScore;
  final double? keywordScore;
  final String? matchedSnippet;
  final String explanation;

  SearchExplanation copyWith({
    double? semanticScore,
    double? keywordScore,
    String? matchedSnippet,
    String? explanation,
  }) => SearchExplanation(
      semanticScore: semanticScore ?? this.semanticScore,
      keywordScore: keywordScore ?? this.keywordScore,
      matchedSnippet: matchedSnippet ?? this.matchedSnippet,
      explanation: explanation ?? this.explanation,
    );

  @override
  List<Object?> get props => [
        semanticScore,
        keywordScore,
        matchedSnippet,
        explanation,
      ];
}
