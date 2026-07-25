import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../domain/usecases/perform_search.dart';
import '../domain/services/search_history_service.dart';
import '../domain/services/search_suggestion_service.dart';

// Provides the fully constructed usecase via GetIt singletons
final performSearchUseCaseProvider = Provider<PerformSearchUseCase>((ref) {
  return sl<PerformSearchUseCase>();
});

final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  return sl<SearchHistoryService>();
});

final searchSuggestionServiceProvider = Provider<SearchSuggestionService>((ref) {
  return sl<SearchSuggestionService>();
});
