import 'package:aura/core/widgets/aura_document_tile.dart';
import 'package:aura/core/widgets/aura_prompt_dialog.dart';
import 'package:aura/core/widgets/aura_search_field.dart';
import 'package:aura/features/search/domain/entities/search_suggestion.dart';
import 'package:aura/features/search/presentation/widgets/aura_suggestion_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

void _noop() {}

Future<void> _match(WidgetTester tester, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

const List<SearchSuggestion> _suggestions = <SearchSuggestion>[
  SearchSuggestion(text: 'thermodynamics', type: SuggestionType.history),
  SearchSuggestion(text: 'eigenvalues', type: SuggestionType.frequent),
  SearchSuggestion(text: 'photosynthesis pathway', type: SuggestionType.ai),
];

void main() {
  group('Step 7 components (Design System rendering)', () {
    testWidgets('search field - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SearchFieldSpecimen()));
      await _match(tester, 'step7_search_field_light');
    });
    testWidgets('search field - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SearchFieldSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step7_search_field_dark');
    });
    testWidgets('search field - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SearchFieldSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step7_search_field_textscale200');
    });

    testWidgets('suggestion list - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SuggestionSpecimen()));
      await _match(tester, 'step7_suggestions_light');
    });
    testWidgets('suggestion list - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SuggestionSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step7_suggestions_dark');
    });
    testWidgets('suggestion list - 200%', (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _SuggestionSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step7_suggestions_textscale200');
    });

    testWidgets('document tile with overflow - light',
        (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _TileOverflowSpecimen()));
      await _match(tester, 'step7_tile_overflow_light');
    });
    testWidgets('document tile with overflow - dark',
        (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _TileOverflowSpecimen()),
          brightness: Brightness.dark);
      await _match(tester, 'step7_tile_overflow_dark');
    });
    testWidgets('document tile with overflow - 200%',
        (WidgetTester tester) async {
      await pumpGolden(tester, const _Frame(child: _TileOverflowSpecimen()),
          textScale: 2.0);
      await _match(tester, 'step7_tile_overflow_textscale200');
    });

    testWidgets('prompt dialog - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _PromptLauncher());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _match(tester, 'step7_prompt_dialog_light');
    });
    testWidgets('prompt dialog - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _PromptLauncher(),
          brightness: Brightness.dark);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _match(tester, 'step7_prompt_dialog_dark');
    });
  });
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      );
}

class _SearchFieldSpecimen extends StatelessWidget {
  const _SearchFieldSpecimen();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AuraSearchField(hintText: 'Search workspaces...'),
          const SizedBox(height: 16),
          AuraSearchField(
            hintText: 'Search workspaces...',
            controller: TextEditingController(text: 'thermodynamics'),
          ),
          const SizedBox(height: 16),
          const AuraSearchField(
            variant: AuraSearchFieldVariant.launcher,
            hintText: 'Search',
          ),
        ],
      );
}

class _SuggestionSpecimen extends StatelessWidget {
  const _SuggestionSpecimen();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 220,
        child: AuraSuggestionList(
          suggestions: _suggestions,
          onSelected: (_) {},
        ),
      );
}

class _TileOverflowSpecimen extends StatelessWidget {
  const _TileOverflowSpecimen();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AuraDocumentTile(
            title: 'Lecture Notes Week 1',
            subtitle: 'Physics',
            fileType: AuraFileType.pdf,
            onTap: _noop,
            onMoreActions: _noop,
          ),
          SizedBox(height: 12),
          AuraDocumentTile(
            title: 'A pinned document with a long title that wraps two lines',
            subtitle: 'Chemistry',
            fileType: AuraFileType.doc,
            onTap: _noop,
            onMoreActions: _noop,
          ),
        ],
      );
}

class _PromptLauncher extends StatelessWidget {
  const _PromptLauncher();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => AuraPromptDialog.show<String>(
              context: context,
              title: 'Gemini API key',
              message: 'The key is stored encrypted on this device.',
              confirmLabel: 'Save',
              hintText: 'Paste your key',
              obscureText: true,
              onSubmit: (String value) async => value,
            ),
            child: const Text('open'),
          ),
        ),
      );
}
