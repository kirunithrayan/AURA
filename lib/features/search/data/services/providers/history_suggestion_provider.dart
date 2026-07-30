import '../../../domain/entities/search_suggestion.dart';
import '../../../domain/services/search_history_service.dart';
import '../../../domain/services/search_suggestion_provider.dart';

class HistorySuggestionProvider implements SuggestionProvider {

  HistorySuggestionProvider(this._historyService);
  final SearchHistoryService _historyService;

  @override
  String get providerId => 'history';

  @override
  Future<List<SearchSuggestion>> getSuggestions(String partialQuery) async {
    final recent = await _historyService.getRecentQueries(limit: 10);
    
    // Sort pinned queries first
    recent.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return b.lastUsed.compareTo(a.lastUsed);
    });

    final filtered = partialQuery.isEmpty 
        ? recent 
        : recent.where((e) => e.query.toLowerCase().contains(partialQuery.toLowerCase())).toList();

    return filtered
        .map((e) => SearchSuggestion(text: e.query, type: SuggestionType.history))
        .take(5)
        .toList();
  }
}
