enum SuggestionType {
  history,
  frequent,
  ai,
}

class SearchSuggestion {

  const SearchSuggestion({
    required this.text,
    required this.type,
  });
  final String text;
  final SuggestionType type;

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
