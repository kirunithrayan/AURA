import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/search_suggestions_provider.dart';

import '../widgets/aura_suggestion_list.dart';
import '../widgets/result_section.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../../core/widgets/aura_search_field.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChanged);
    // The body chooses between suggestions and results using
    // `_searchFocus.hasFocus`, so focus changes have to rebuild the screen.
    _searchFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _searchFocus.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
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
      appBar: const AuraAppBar(
        variant: AuraAppBarVariant.nested,
        title: 'Search',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AuraSpacing.screenMargin,
                vertical: AuraSpacing.gapTight,
              ),
              child: AuraSearchField(
                controller: _searchController,
                focusNode: _searchFocus,
                hintText: 'Search workspaces...',
                onChanged: _onInstantSearch,
                onSubmitted: _onSearch,
                onClear: _onClear,
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                // Suggestions are shrink-wrapped, so they must start beneath
                // the search field rather than float in the middle of the body.
                // AnimatedSwitcher exposes no `alignment`; this is its default
                // layout builder with the stack aligned to the top.
                layoutBuilder: (Widget? currentChild,
                        List<Widget> previousChildren) =>
                    Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
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
        data: (suggestions) => AuraSuggestionList(
          suggestions: suggestions.cast(),
          onSelected: (suggestion) {
            _searchController.text = suggestion.text;
            _onSearch(suggestion.text);
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
              title: 'No results found',
              message: 'Try different keywords.',
            ),
          );
        }
        if (results.isEmpty) {
          return const Center(
            child: AuraEmptyState(
              title: 'Global Search',
              message: 'Type to start searching across your workspaces.',
            ),
          );
        }

        return ResultSection(results: results.cast());
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
