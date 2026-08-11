import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../features/ai/rag/domain/entities/citation.dart';
import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';
import 'aura_chip.dart';

/// A single focused AI answer: markdown body, optional citations, an in-flight
/// indicator, and an error state.
///
/// Built from the rendering primitives the routed Ask AURA conversation already
/// uses (markdown body + citation chips) so the two surfaces stay consistent
/// without either one depending on the other.
class AuraAnswerBlock extends StatelessWidget {
  const AuraAnswerBlock({
    super.key,
    required this.markdown,
    this.citations = const <Citation>[],
    this.isStreaming = false,
    this.errorMessage,
    this.onCitationTap,
  });

  final String markdown;
  final List<Citation> citations;
  final bool isStreaming;

  /// When non-null the block renders the error treatment instead of an answer.
  final String? errorMessage;
  final ValueChanged<Citation>? onCitationTap;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final String? error = errorMessage;

    if (error != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: AuraIconTokens.sizeSm,
            color: colors.statusError,
          ),
          const SizedBox(width: AuraSpacing.gapTight),
          Expanded(
            child: Text(
              error,
              style: AuraTypography.body.copyWith(color: colors.statusError),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (markdown.isNotEmpty)
          MarkdownBody(
            data: markdown,
            styleSheet: MarkdownStyleSheet(
              p: AuraTypography.body.copyWith(color: colors.contentPrimary),
              code: AuraTypography.caption.copyWith(color: colors.contentSecondary),
              listBullet:
                  AuraTypography.body.copyWith(color: colors.contentPrimary),
            ),
          ),
        if (isStreaming) ...<Widget>[
          if (markdown.isNotEmpty) const SizedBox(height: AuraSpacing.gapTight),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: AuraIconTokens.sizeSm,
                height: AuraIconTokens.sizeSm,
                child: CircularProgressIndicator(
                  strokeWidth: AuraBorders.focus,
                  color: colors.actionPrimary,
                ),
              ),
              const SizedBox(width: AuraSpacing.gapTight),
              Text(
                'Thinking…',
                style:
                    AuraTypography.caption.copyWith(color: colors.contentSecondary),
              ),
            ],
          ),
        ],
        if (citations.isNotEmpty) ...<Widget>[
          const SizedBox(height: AuraSpacing.componentGap),
          Wrap(
            spacing: AuraSpacing.gapTight,
            runSpacing: AuraSpacing.gapTight,
            children: <Widget>[
              for (final Citation citation in citations)
                AuraChip(
                  label: '${citation.index}. ${citation.fileName}',
                  onTap: onCitationTap == null
                      ? null
                      : () => onCitationTap!(citation),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
