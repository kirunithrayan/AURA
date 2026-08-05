// AskAuraScreen used to render nothing at all when a turn failed: the error
// status produced no widget, so a missing or rejected API key looked exactly
// like the app hanging. These tests hold the error bubble in place.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/ai/rag/presentation/screens/ask_aura_screen.dart';
import 'package:aura/features/ai/rag/presentation/viewmodels/ask_aura_viewmodel.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_config.dart';
import 'package:aura/features/ai/rag/domain/entities/ai_response.dart';
import 'package:aura/features/ai/rag/domain/services/ai_key_store.dart';
import 'package:aura/features/ai/rag/domain/services/rag_service.dart';

class _FakeKeyStore implements AiKeyStore {
  _FakeKeyStore(this._key);

  final String? _key;

  @override
  Future<String?> readApiKey() async => _key;
  @override
  Future<bool> hasApiKey() async => _key != null;
  @override
  Future<void> saveApiKey(String apiKey) async {}
  @override
  Future<void> clearApiKey() async {}
}

class _ThrowingRagService implements RAGService {
  _ThrowingRagService(this.error);

  final Object error;

  @override
  Future<AiResponse> askDocument(String query, AiConfig config) async =>
      throw error;

  @override
  Stream<AiResponse> streamAskDocument(String query, AiConfig config) =>
      Stream.error(error);
}

class _AnsweringRagService implements RAGService {
  @override
  Future<AiResponse> askDocument(String query, AiConfig config) async =>
      const AiResponse(text: 'an answer', provider: 'gemini', model: 'm');

  @override
  Stream<AiResponse> streamAskDocument(String query, AiConfig config) =>
      Stream.value(
        const AiResponse(text: 'an answer', provider: 'gemini', model: 'm'),
      );
}

Widget _app({
  required RAGService ragService,
  required String? apiKey,
}) =>
    ProviderScope(
      overrides: [
        askAuraViewModelProvider.overrideWith(
          (ref) => AskAuraViewModel(
            ragService,
            const AiConfig(apiKey: ''),
            _FakeKeyStore(apiKey),
          ),
        ),
      ],
      child: const MaterialApp(
        home: AskAuraScreen(workspaceId: 'ws-1'),
      ),
    );

Future<void> _ask(WidgetTester tester, String question) async {
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), question);
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();
}

void main() {
  group('AskAuraScreen error display', () {
    testWidgets('a missing API key tells the user where to set one',
        (tester) async {
      await tester.pumpWidget(
        _app(ragService: _AnsweringRagService(), apiKey: null),
      );

      await _ask(tester, 'what is in my documents?');

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('No API key configured'), findsOneWidget);
      expect(find.textContaining('Settings'), findsOneWidget);
    });

    testWidgets('a provider failure is shown rather than swallowed',
        (tester) async {
      await tester.pumpWidget(_app(
        ragService: _ThrowingRagService(Exception('Gemini returned 404')),
        apiKey: 'a-key',
      ));

      await _ask(tester, 'summarise the budget');

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('404'), findsOneWidget);
    });

    testWidgets('the question stays visible alongside the error',
        (tester) async {
      await tester.pumpWidget(
        _app(ragService: _AnsweringRagService(), apiKey: null),
      );

      await _ask(tester, 'my question text');

      expect(find.text('my question text'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('a successful answer shows no error bubble', (tester) async {
      await tester.pumpWidget(
        _app(ragService: _AnsweringRagService(), apiKey: 'a-key'),
      );

      await _ask(tester, 'what is in my documents?');

      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.textContaining('an answer'), findsWidgets);
    });
  });
}
