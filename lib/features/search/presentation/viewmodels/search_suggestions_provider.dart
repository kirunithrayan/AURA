import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../di/search_providers.dart';

final searchSuggestionsProvider = FutureProvider.autoDispose.family<List<SearchSuggestion>, String>((ref, query) async {
  final service = ref.watch(searchSuggestionServiceProvider);
  return service.getSuggestions(query);
});
