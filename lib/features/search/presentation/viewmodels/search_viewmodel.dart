import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_history_entry.dart';
import '../../di/search_providers.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

part 'search_viewmodel.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  SearchQuery _currentQuery = const SearchQuery(keyword: '');

  @override
  FutureOr<List<SearchResult>> build() async {
    // Initial state is empty results
    return [];
  }

  Future<void> search(String keyword) async {
    _currentQuery = _currentQuery.copyWith(keyword: keyword, offset: 0);
    await _performSearch();
  }

  Future<void> updateFilter(SearchFilter filter) async {
    _currentQuery = _currentQuery.copyWith(filter: filter, offset: 0);
    await _performSearch();
  }

  Future<void> updateSort(String sortField, bool ascending) async {
    _currentQuery = _currentQuery.copyWith(sortField: sortField, ascending: ascending, offset: 0);
    await _performSearch();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasValue) return;
    
    _currentQuery = _currentQuery.copyWith(offset: _currentQuery.offset + _currentQuery.limit);
    
    // Set state to loading but preserve previous data
    state = const AsyncValue.loading();
    
    try {
      final performSearch = ref.read(performSearchUseCaseProvider);
      final newResults = await performSearch(_currentQuery);
      
      final currentResults = state.value ?? [];
      state = AsyncValue.data([...currentResults, ...newResults]);
    } catch (e, st) {
      AppLogger.error('SearchViewModel: loadMore failed', e.toString());
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _performSearch() async {
    if (_currentQuery.keyword.isEmpty && _currentQuery.filter.fileTypes.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final performSearch = ref.read(performSearchUseCaseProvider);
      final results = await performSearch(_currentQuery);
      
      // Record in history if keyword is present
      if (_currentQuery.keyword.trim().isNotEmpty) {
        try {
          final historyService = ref.read(searchHistoryServiceProvider);
          await historyService.addQuery(SearchHistoryEntry(
            id: const Uuid().v4(),
            query: _currentQuery.keyword.trim(),
            searchedAt: DateTime.now(),
            lastUsed: DateTime.now(),
            hitCount: 1,
            pinned: false,
            resultCount: results.length,
          ));
        } catch (e) {
          AppLogger.error('SearchViewModel: failed to record history', e.toString());
        }
      }
      
      state = AsyncValue.data(results);
    } catch (e, st) {
      AppLogger.error('SearchViewModel: search failed', e.toString());
      state = AsyncValue.error(e, st);
    }
  }
}
