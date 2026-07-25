import '../../domain/entities/search_suggestion.dart';
import '../../domain/services/search_suggestion_provider.dart';
import '../../domain/services/search_suggestion_service.dart';
import '../../../../core/utils/app_logger.dart';

class SearchSuggestionServiceImpl implements SearchSuggestionService {
  final List<SuggestionProvider> _providers = [];

  @override
  void registerProvider(SuggestionProvider provider) {
    if (!_providers.any((p) => p.providerId == provider.providerId)) {
      _providers.add(provider);
    }
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(String partialQuery) async {
    if (partialQuery.trim().isEmpty) {
      return _getEmptyStateSuggestions();
    }

    final results = <SearchSuggestion>[];
    for (final provider in _providers) {
      try {
        final suggestions = await provider.getSuggestions(partialQuery);
        for (final suggestion in suggestions) {
          if (!results.any((r) => r.text == suggestion.text)) {
            results.add(suggestion);
          }
        }
      } catch (e) {
        AppLogger.error('SearchSuggestionService: Provider ${provider.providerId} failed', e.toString());
      }
    }

    return results;
  }

  Future<List<SearchSuggestion>> _getEmptyStateSuggestions() async {
    final results = <SearchSuggestion>[];
    for (final provider in _providers) {
      try {
        final suggestions = await provider.getSuggestions('');
        for (final suggestion in suggestions) {
          if (!results.any((r) => r.text == suggestion.text)) {
            results.add(suggestion);
          }
        }
      } catch (e) {
        AppLogger.error('SearchSuggestionService: Provider ${provider.providerId} failed', e.toString());
      }
    }
    return results;
  }
}
