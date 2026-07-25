import '../entities/search_suggestion.dart';
import 'search_suggestion_provider.dart';

abstract class SearchSuggestionService {
  void registerProvider(SuggestionProvider provider);
  Future<List<SearchSuggestion>> getSuggestions(String partialQuery);
}
