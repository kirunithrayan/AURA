import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/core/widgets/aura_answer_block.dart';
import 'package:aura/core/widgets/aura_chip.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_config.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_response.dart';
import 'package:aura/features/ai/rag/domain/entities/citation.dart';
import 'package:aura/features/ai/rag/domain/services/ai_key_store.dart';
import 'package:aura/features/ai/rag/domain/services/rag_service.dart';
import 'package:aura/features/ai/rag/presentation/viewmodels/explain_state.dart';
import 'package:aura/features/ai/rag/presentation/viewmodels/explain_viewmodel.dart';
import 'package:aura/features/ai/rag/presentation/widgets/explain_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Step 8 Ask AURA — selection-triggered explanation.
///
/// The routed multi-turn conversation is deliberately untouched; these tests
/// only cover the new explain surface.

const Citation _citation = Citation(
  index: 1,
  documentId: 'doc-1',
  workspaceId: 'ws-1',
  fileName: 'Lecture Notes.pdf',
  snippet: 'an excerpt',
  chunkIndex: 0,
  similarityScore: 0.9,
);

AiResponse _response(String text, {List<Citation> citations = const <Citation>[]}) =>
    AiResponse(
      text: text,
      citations: citations,
      provider: 'gemini',
      model: 'test',
    );

// Narrow stand-ins: the fake overrides explain() and never calls super, so
// these dependencies are never exercised.
class _FakeRag implements RAGService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConfig implements AiConfig {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeKeyStore implements AiKeyStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Test double that never touches the real RAG pipeline.
class _FakeExplainViewModel extends ExplainViewModel {
  _FakeExplainViewModel(this._state)
      : super(_FakeRag(), _FakeConfig(), _FakeKeyStore());
  final ExplainState _state;

  @override
  Future<void> explain(String selection) async {
    state = ExplainState(
      status: _state.status,
      selection: selection,
      response: _state.response,
      errorMessage: _state.errorMessage,
    );
  }
}

Widget _harness({
  required ExplainState state,
  String selection = 'photosynthesis',
}) =>
    ProviderScope(
      overrides: <Override>[
        explainViewModelProvider
            .overrideWith((ref) => _FakeExplainViewModel(state)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ExplainSheetContent(selection: selection),
        ),
      ),
    );

void main() {
  group('AuraAnswerBlock', () {
    Widget block(AuraAnswerBlock child, {double textScale = 1.0}) => MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (BuildContext context, Widget? built) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: built!,
          ),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        );

    testWidgets('renders the answer markdown', (WidgetTester tester) async {
      await tester.pumpWidget(block(const AuraAnswerBlock(markdown: 'Hello answer')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Hello answer'), findsOneWidget);
    });

    testWidgets('renders the error treatment instead of an answer',
        (WidgetTester tester) async {
      await tester.pumpWidget(block(
        const AuraAnswerBlock(markdown: '', errorMessage: 'No API key configured'),
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('No API key configured'), findsOneWidget);
    });

    testWidgets('renders citations as chips and reports taps',
        (WidgetTester tester) async {
      Citation? tapped;
      await tester.pumpWidget(block(AuraAnswerBlock(
        markdown: 'Answer',
        citations: const <Citation>[_citation],
        onCitationTap: (Citation c) => tapped = c,
      )));
      await tester.pumpAndSettle();

      expect(find.byType(AuraChip), findsOneWidget);
      await tester.tap(find.byType(AuraChip));
      expect(tapped, _citation);
    });

    testWidgets('no overflow at 200% text scale', (WidgetTester tester) async {
      await tester.pumpWidget(block(
        const AuraAnswerBlock(
          markdown: 'A reasonably long explanation that must wrap rather than clip.',
          citations: <Citation>[_citation],
          isStreaming: true,
        ),
        textScale: 2.0,
      ));
      // A progress indicator animates forever, so settle is not applicable.
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Explain sheet', () {
    testWidgets('shows the selected text and a streaming indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        state: const ExplainState(status: ExplainStatus.loading),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('photosynthesis'), findsOneWidget);
      expect(find.text('Thinking…'), findsOneWidget);
    });

    testWidgets('renders a completed answer', (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        state: ExplainState(
          status: ExplainStatus.complete,
          response: _response('The process by which plants convert light.'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('convert light'), findsOneWidget);
      expect(find.text('Thinking…'), findsNothing);
    });

    testWidgets('renders the error state from the stream',
        (WidgetTester tester) async {
      await tester.pumpWidget(_harness(
        state: const ExplainState(
          status: ExplainStatus.error,
          errorMessage: 'GeminiProvider stream error: 404',
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('404'), findsOneWidget);
    });

    testWidgets('passes the raw selection through unchanged',
        (WidgetTester tester) async {
      const String raw = '  mitochondria are the powerhouse  ';
      await tester.pumpWidget(_harness(
        state: const ExplainState(status: ExplainStatus.loading),
        selection: raw,
      ));
      await tester.pump();
      await tester.pump();

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(ExplainSheetContent)),
      );
      // The notifier received the selection verbatim, with no prefix added.
      expect(container.read(explainViewModelProvider).selection, raw);
    });
  });

  group('ExplainState', () {
    test('is independent of the conversation state', () {
      const ExplainState s = ExplainState();
      expect(s.status, ExplainStatus.initial);
      expect(s.response, isNull);
      expect(s.errorMessage, isNull);
    });
  });
}
