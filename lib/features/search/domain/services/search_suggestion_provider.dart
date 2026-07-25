import '../entities/search_suggestion.dart';

abstract class SuggestionProvider {
  String get providerId;
  Future<List<SearchSuggestion>> getSuggestions(String partialQuery);
}
