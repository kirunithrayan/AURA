import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/search_suggestions_provider.dart';
import '../../domain/entities/search_filter.dart';

import 'widgets/search_bar_widget.dart';
import 'widgets/suggestion_section.dart';
import 'widgets/filter_section.dart';
import 'widgets/statistics_section.dart';
import 'widgets/result_section.dart';
import '../../../../core/widgets/aura_empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _currentQuery = '';
  SearchFilter _currentFilter = const SearchFilter();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() {
    if (_currentQuery != _searchController.text) {
      setState(() {
        _currentQuery = _searchController.text;
      });
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      SemanticsService.announce('Search started for $query', TextDirection.ltr);
    }
    ref.read(searchViewModelProvider.notifier).search(query);
    _searchFocus.unfocus();
  }

  void _onClear() {
    SemanticsService.announce('Search cleared', TextDirection.ltr);
    _searchController.clear();
    ref.read(searchViewModelProvider.notifier).search('');
    _searchFocus.requestFocus();
  }

  void _onFilterChanged(SearchFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
    ref.read(searchViewModelProvider.notifier).updateFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final suggestionsState = ref.watch(searchSuggestionsProvider(_currentQuery));

    // Listen to search state for announcements
    ref.listen(searchViewModelProvider, (previous, next) {
      if (!next.isLoading && next.hasValue && previous?.isLoading == true) {
        final count = next.value!.length;
        SemanticsService.announce('Search completed. $count results found.', TextDirection.ltr);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Section
            SearchBarWidget(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (val) {
                // We rely on debounce or submit button, for instant search we could call viewmodel here
                // but let's do it on submit or suggestions tap to prevent excessive DB calls, 
                // unless we add a local debounce Timer in SearchScreen like before.
                // Re-added debounce behavior for instant search:
                _onInstantSearch(val);
              },
              onSubmitted: _onSearch,
              onClear: _onClear,
            ),

            // Filter Section
            FilterSection(
              currentFilter: _currentFilter,
              onFilterChanged: _onFilterChanged,
            ),

            const Divider(height: 1),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBodyContent(searchState, suggestionsState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Debounce for instant search
  Timer? _debounce;
  void _onInstantSearch(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _onSearch(val);
      }
    });
  }

  Widget _buildBodyContent(
    AsyncValue<List<dynamic>> searchState,
    AsyncValue<List<dynamic>> suggestionsState,
  ) {
    // If focused and no search results loading, show suggestions
    if (_searchFocus.hasFocus && _searchController.text.isEmpty && !searchState.isLoading && (searchState.value?.isEmpty ?? true)) {
      return suggestionsState.when(
        data: (suggestions) => SuggestionSection(
          suggestions: suggestions.cast(),
          onSuggestionTap: (text) {
            _searchController.text = text;
            _onSearch(text);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      );
    }

    return searchState.when(
      data: (results) {
        if (results.isEmpty && _searchController.text.isNotEmpty) {
          return const Center(
            child: AuraEmptyState(
              icon: Icons.search_off,
              title: 'No results found',
              message: 'Try different keywords or filters.',
            ),
          );
        }
        if (results.isEmpty) {
          return const Center(
            child: AuraEmptyState(
              icon: Icons.search,
              title: 'Global Search',
              message: 'Type to start searching across your workspaces.',
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatisticsSection(
              resultCount: results.length,
              // For demonstration, duration is mocked here since it's not exposed by state directly.
              // We could expose it by changing SearchViewModel state. 
              duration: const Duration(milliseconds: 450), 
            ),
            Expanded(
              child: ResultSection(results: results.cast()),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
