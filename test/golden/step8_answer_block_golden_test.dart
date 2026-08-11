import 'package:aura/core/widgets/aura_answer_block.dart';
import 'package:aura/features/ai/rag/domain/entities/citation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/aura_test_harness.dart';

const Citation _citation = Citation(
  index: 1,
  documentId: 'doc-1',
  workspaceId: 'ws-1',
  fileName: 'Lecture Notes.pdf',
  snippet: 'an excerpt',
  chunkIndex: 0,
  similarityScore: 0.9,
);

Future<void> _match(WidgetTester tester, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

class _Answered extends StatelessWidget {
  const _Answered();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: AuraAnswerBlock(
            markdown:
                'Photosynthesis converts light energy into chemical energy, '
                'storing it as glucose.',
            citations: <Citation>[_citation],
          ),
        ),
      );
}

class _Errored extends StatelessWidget {
  const _Errored();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: AuraAnswerBlock(
            markdown: '',
            errorMessage: 'No API key configured. Add one in Settings.',
          ),
        ),
      );
}

void main() {
  group('Step 8 AuraAnswerBlock', () {
    testWidgets('answered - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Answered());
      await _match(tester, 'step8_answer_block_light');
    });

    testWidgets('answered - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Answered(), brightness: Brightness.dark);
      await _match(tester, 'step8_answer_block_dark');
    });

    testWidgets('answered - 200% text scale', (WidgetTester tester) async {
      await pumpGolden(tester, const _Answered(), textScale: 2.0);
      await _match(tester, 'step8_answer_block_textscale200');
    });

    testWidgets('error - light', (WidgetTester tester) async {
      await pumpGolden(tester, const _Errored());
      await _match(tester, 'step8_answer_block_error_light');
    });

    testWidgets('error - dark', (WidgetTester tester) async {
      await pumpGolden(tester, const _Errored(), brightness: Brightness.dark);
      await _match(tester, 'step8_answer_block_error_dark');
    });
  });
}
