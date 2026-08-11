import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/design_tokens.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/aura_answer_block.dart';
import '../../../../../core/widgets/aura_sheet.dart';
import '../../domain/entities/citation.dart';
import '../viewmodels/explain_state.dart';
import '../viewmodels/explain_viewmodel.dart';

/// Opens the selection-triggered explanation surface for [selection].
///
/// The selected text is passed through unchanged.
Future<void> showExplainSheet({
  required BuildContext context,
  required String selection,
}) =>
    AuraSheet.show<void>(
      context: context,
      title: 'Explain with AURA',
      variant: AuraSheetVariant.explain,
      child: ExplainSheetContent(selection: selection),
    );

/// The body of the explanation sheet.
class ExplainSheetContent extends ConsumerStatefulWidget {
  const ExplainSheetContent({super.key, required this.selection});

  final String selection;

  @override
  ConsumerState<ExplainSheetContent> createState() =>
      _ExplainSheetContentState();
}

class _ExplainSheetContentState extends ConsumerState<ExplainSheetContent> {
  @override
  void initState() {
    super.initState();
    // Kick off the request once the sheet is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(explainViewModelProvider.notifier).explain(widget.selection);
      }
    });
  }

  void _openCitation(Citation citation) {
    Navigator.of(context).pop();
    context.pushNamed(
      AppRoutes.documentViewer,
      pathParameters: <String, String>{'id': citation.documentId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final ExplainState state = ref.watch(explainViewModelProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.componentGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The text being explained, so the answer has visible context.
          Text(
            widget.selection.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AuraTypography.caption.copyWith(
              color: colors.contentSecondary,
            ),
          ),
          const SizedBox(height: AuraSpacing.componentGap),
          AuraAnswerBlock(
            markdown: state.response?.text ?? '',
            citations: state.response?.citations ?? const <Citation>[],
            isStreaming: state.status == ExplainStatus.loading ||
                state.status == ExplainStatus.streaming,
            errorMessage: state.status == ExplainStatus.error
                ? state.errorMessage
                : null,
            onCitationTap: _openCitation,
          ),
        ],
      ),
    );
  }
}
