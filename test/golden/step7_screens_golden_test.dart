import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/ai/rag/domain/services/ai_key_store.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';
import 'package:aura/features/search/domain/entities/search_result.dart';
import 'package:aura/features/search/domain/entities/search_suggestion.dart';
import 'package:aura/features/search/presentation/screens/search_screen.dart';
import 'package:aura/features/search/presentation/viewmodels/search_suggestions_provider.dart';
import 'package:aura/features/search/presentation/viewmodels/search_viewmodel.dart';
import 'package:aura/features/settings/presentation/screens/settings_screen.dart';
import 'package:aura/features/workspace/domain/entities/workspace.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:aura/features/workspace/presentation/screens/workspace_detail_screen.dart';
import 'package:aura/features/workspace/presentation/viewmodels/workspace_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

const String _kWorkspaceId = 'ws-1';

Future<void> _match(WidgetTester tester, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const Workspace _workspace = Workspace(
  id: _kWorkspaceId,
  name: 'Organic Chemistry',
  description: 'Reaction mechanisms and lab notes for the autumn term.',
  createdAt: 1735689600000,
  updatedAt: 1735689600000,
);

WorkspaceFile _file(String id, String name, String ext) => WorkspaceFile(
      id: id,
      workspaceId: _kWorkspaceId,
      fileName: name,
      filePath: '/tmp/$name',
      extension: ext,
      createdAt: 1735689600000,
      modifiedAt: 1735689600000,
      importedAt: 1735689600000,
    );

DocumentMetadata _meta(String id, String name, String ext) => DocumentMetadata(
      id: id,
      workspaceId: _kWorkspaceId,
      fileName: name,
      fileExtension: ext,
      filePath: '/tmp/$name',
      createdAt: 1735689600000,
      modifiedAt: 1735689600000,
      importedAt: 1735689600000,
    );

SearchResult _result(String id, String name, String ext) => SearchResult(
      metadata: _meta(id, name, ext),
      score: 0.9,
      searchEngineType: 'keyword',
    );

/// Test-only notifier that yields a fixed Course state, so no repository,
/// database, or file system is touched.
class _FakeCourseViewModel extends WorkspaceDetailViewModel {
  _FakeCourseViewModel(this._state);
  final WorkspaceDetailState _state;

  @override
  Future<WorkspaceDetailState> build(String workspaceId) async => _state;
}

class _FakeSearchViewModel extends SearchViewModel {
  _FakeSearchViewModel(this._results);
  final List<SearchResult> _results;

  @override
  Future<List<SearchResult>> build() async => _results;
}

/// Minimal in-memory [AiKeyStore]; the production Gemini flow is untouched.
class _FakeAiKeyStore implements AiKeyStore {
  _FakeAiKeyStore({required this.hasKey});
  final bool hasKey;

  @override
  Future<void> clearApiKey() async {}
  @override
  Future<bool> hasApiKey() async => hasKey;
  @override
  Future<String?> readApiKey() async => hasKey ? 'test-key' : null;
  @override
  Future<void> saveApiKey(String apiKey) async {}
}

List<Override> _courseOverrides(WorkspaceDetailState state) => <Override>[
      workspaceDetailViewModelProvider(_kWorkspaceId)
          .overrideWith(() => _FakeCourseViewModel(state)),
    ];

List<Override> _searchOverrides({
  required List<SearchResult> results,
  List<SearchSuggestion> suggestions = const <SearchSuggestion>[],
}) =>
    <Override>[
      searchViewModelProvider.overrideWith(() => _FakeSearchViewModel(results)),
      searchSuggestionsProvider('').overrideWith((Ref ref) async => suggestions),
    ];

void main() {
  // Settings resolves AiKeyStore through GetIt at construction.
  void registerKeyStore({required bool hasKey}) {
    if (sl.isRegistered<AiKeyStore>()) {
      sl.unregister<AiKeyStore>();
    }
    sl.registerSingleton<AiKeyStore>(_FakeAiKeyStore(hasKey: hasKey));
  }

  final WorkspaceDetailState populated = WorkspaceDetailState(
    workspace: _workspace,
    allFiles: <WorkspaceFile>[
      _file('f1', 'Lecture Notes Week 1.pdf', 'pdf'),
      _file('f2', 'Reaction mechanisms summary.docx', 'docx'),
    ],
    pinnedFiles: <WorkspaceFile>[_file('f1', 'Lecture Notes Week 1.pdf', 'pdf')],
  );

  const WorkspaceDetailState empty = WorkspaceDetailState(
    workspace: _workspace,
  );

  group('Step 7 — Course screen', () {
    testWidgets('pinned + documents - light', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const WorkspaceDetailScreen(workspaceId: _kWorkspaceId),
        overrides: _courseOverrides(populated),
      );
      await _match(tester, 'step7_course_populated_light');
    });

    testWidgets('pinned + documents - dark', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const WorkspaceDetailScreen(workspaceId: _kWorkspaceId),
        brightness: Brightness.dark,
        overrides: _courseOverrides(populated),
      );
      await _match(tester, 'step7_course_populated_dark');
    });

    testWidgets('pinned + documents - 200%', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const WorkspaceDetailScreen(workspaceId: _kWorkspaceId),
        textScale: 2.0,
        overrides: _courseOverrides(populated),
      );
      await _match(tester, 'step7_course_populated_textscale200');
    });

    testWidgets('empty - light', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const WorkspaceDetailScreen(workspaceId: _kWorkspaceId),
        overrides: _courseOverrides(empty),
      );
      await _match(tester, 'step7_course_empty_light');
    });

    testWidgets('empty - dark', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const WorkspaceDetailScreen(workspaceId: _kWorkspaceId),
        brightness: Brightness.dark,
        overrides: _courseOverrides(empty),
      );
      await _match(tester, 'step7_course_empty_dark');
    });
  });

  group('Step 7 — Search screen', () {
    final List<SearchResult> results = <SearchResult>[
      _result('d1', 'Lecture Notes Week 1.pdf', 'pdf'),
      _result('d2', 'Reaction mechanisms summary.docx', 'docx'),
    ];

    testWidgets('results - light', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        overrides: _searchOverrides(results: results),
      );
      await _match(tester, 'step7_search_results_light');
    });

    testWidgets('results - dark', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        brightness: Brightness.dark,
        overrides: _searchOverrides(results: results),
      );
      await _match(tester, 'step7_search_results_dark');
    });

    testWidgets('results - 200%', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        textScale: 2.0,
        overrides: _searchOverrides(results: results),
      );
      await _match(tester, 'step7_search_results_textscale200');
    });

    testWidgets('empty prompt - light', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        overrides: _searchOverrides(results: const <SearchResult>[]),
      );
      await _match(tester, 'step7_search_empty_light');
    });

    testWidgets('empty prompt - dark', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        brightness: Brightness.dark,
        overrides: _searchOverrides(results: const <SearchResult>[]),
      );
      await _match(tester, 'step7_search_empty_dark');
    });

    // Suggestions render when the field holds focus and its text is empty.
    // Tapping the field focuses it; the screen listens to the focus node, so
    // that rebuilds the body. No text is entered, so the debounce never arms.
    // 200% for the suggestion rows themselves is covered at component level in
    // step7_components_golden_test.dart.
    const List<SearchSuggestion> suggestions = <SearchSuggestion>[
      SearchSuggestion(text: 'thermodynamics', type: SuggestionType.history),
      SearchSuggestion(text: 'eigenvalues', type: SuggestionType.frequent),
      SearchSuggestion(
        text: 'photosynthesis pathway',
        type: SuggestionType.ai,
      ),
    ];

    testWidgets('suggestions - light', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        overrides: _searchOverrides(
          results: const <SearchResult>[],
          suggestions: suggestions,
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await _match(tester, 'step7_search_suggestions_light');
    });

    testWidgets('suggestions - dark', (WidgetTester tester) async {
      await pumpGolden(
        tester,
        const SearchScreen(),
        brightness: Brightness.dark,
        overrides: _searchOverrides(
          results: const <SearchResult>[],
          suggestions: suggestions,
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await _match(tester, 'step7_search_suggestions_dark');
    });
  });

  group('Step 7 — Settings screen', () {
    testWidgets('key set - light', (WidgetTester tester) async {
      registerKeyStore(hasKey: true);
      await pumpGolden(tester, const SettingsScreen());
      await _match(tester, 'step7_settings_keyset_light');
    });

    testWidgets('key set - dark', (WidgetTester tester) async {
      registerKeyStore(hasKey: true);
      await pumpGolden(tester, const SettingsScreen(),
          brightness: Brightness.dark);
      await _match(tester, 'step7_settings_keyset_dark');
    });

    testWidgets('key unset - light', (WidgetTester tester) async {
      registerKeyStore(hasKey: false);
      await pumpGolden(tester, const SettingsScreen());
      await _match(tester, 'step7_settings_keyunset_light');
    });

    testWidgets('key set - 200%', (WidgetTester tester) async {
      registerKeyStore(hasKey: true);
      await pumpGolden(tester, const SettingsScreen(), textScale: 2.0);
      await _match(tester, 'step7_settings_keyset_textscale200');
    });
  });
}
