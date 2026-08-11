import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/design_tokens.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/aura_section_header.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/recommendation_type.dart';
import '../viewmodels/recommendations_viewmodel.dart';

/// Restyled to design tokens in Step 7. Behavior, data source, provider, and
/// recommendation logic are unchanged. Type glyphs are monochrome: the type is
/// already named in text on every card, so colour is not carrying meaning.
class RecommendationsSection extends ConsumerWidget {

  const RecommendationsSection({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider(workspaceId));

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AuraSpacing.screenMargin,
                AuraSpacing.sectionGap,
                AuraSpacing.screenMargin,
                AuraSpacing.componentGap,
              ),
              child: AuraSectionHeader(title: 'Recommended for You'),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuraSpacing.screenMargin,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return _RecommendationCard(recommendation: rec);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _RecommendationCard extends StatelessWidget {

  const _RecommendationCard({required this.recommendation});
  final Recommendation recommendation;

  IconData get _icon => switch (recommendation.type) {
        RecommendationType.continueReading => Icons.menu_book,
        RecommendationType.recentlyViewed => Icons.history,
        RecommendationType.aiRecommended => Icons.auto_awesome,
        RecommendationType.related => Icons.link,
        RecommendationType.trendingInWorkspace => Icons.trending_up,
      };

  String get _typeLabel => switch (recommendation.type) {
        RecommendationType.continueReading => 'Continue Reading',
        RecommendationType.recentlyViewed => 'Recently Viewed',
        RecommendationType.aiRecommended => 'AI Recommended',
        RecommendationType.related => 'Related Content',
        RecommendationType.trendingInWorkspace => 'Trending',
      };

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;

    return Padding(
      padding: const EdgeInsets.only(right: AuraSpacing.componentGap),
      child: Material(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.documentViewer,
            pathParameters: {'id': recommendation.document.metadata.id},
          ),
          borderRadius: BorderRadius.circular(AuraRadius.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AuraRadius.md),
              border: Border.all(
                color: colors.borderDefault,
                width: AuraBorders.hairline,
              ),
            ),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(AuraSpacing.componentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _icon,
                        size: AuraIconTokens.sizeSm,
                        color: colors.contentTertiary,
                      ),
                      const SizedBox(width: AuraSpacing.gapTight),
                      Expanded(
                        child: Text(
                          _typeLabel,
                          style: AuraTypography.caption.copyWith(
                            color: colors.contentSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AuraSpacing.gapTight),
                  Text(
                    recommendation.document.metadata.fileName,
                    style: AuraTypography.titleSm.copyWith(
                      color: colors.contentPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    recommendation.explanation,
                    style: AuraTypography.caption.copyWith(
                      color: colors.contentSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
