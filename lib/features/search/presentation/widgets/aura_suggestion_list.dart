import 'package:flutter/material.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/search_suggestion.dart';

/// The AURA suggestion list.
///
/// Consumes the existing [SearchSuggestion] entity and its [SuggestionType]
/// unchanged; the suggestion service, its ranking, and its data path are not
/// touched. Lives beside that entity rather than in `core/widgets` so the
/// design-system layer does not take a dependency on a feature's domain.
class AuraSuggestionList extends StatelessWidget {
  const AuraSuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.isLoading = false,
  });

  final List<SearchSuggestion> suggestions;
  final ValueChanged<SearchSuggestion> onSelected;
  final bool isLoading;

  static IconData _glyphFor(SuggestionType type) => switch (type) {
        SuggestionType.history => Icons.history,
        SuggestionType.frequent => Icons.trending_up,
        SuggestionType.ai => Icons.auto_awesome,
      };

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        final SearchSuggestion suggestion = suggestions[index];
        return Semantics(
          button: true,
          label: suggestion.text,
          child: InkWell(
            onTap: () => onSelected(suggestion),
            child: ExcludeSemantics(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AuraLayout.touchTargetMin,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AuraSpacing.screenMargin,
                  vertical: AuraSpacing.gapTight,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _glyphFor(suggestion.type),
                      size: AuraIconTokens.sizeSm,
                      color: colors.contentTertiary,
                    ),
                    const SizedBox(width: AuraSpacing.componentGap),
                    Expanded(
                      child: Text(
                        suggestion.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AuraTypography.body
                            .copyWith(color: colors.contentPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
