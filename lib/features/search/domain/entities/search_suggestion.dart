enum SuggestionType {
  history,
  frequent,
  ai,
}

class SearchSuggestion {
  final String text;
  final SuggestionType type;

  const SearchSuggestion({
    required this.text,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchSuggestion &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          type == other.type;

  @override
  int get hashCode => text.hashCode ^ type.hashCode;
}
