import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/recommendation_type.dart';
import '../viewmodels/recommendations_viewmodel.dart';

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
            Padding(
              padding: AppSpacing.edgeInsetsH16.copyWith(top: 16, bottom: 8),
              child: Text(
                'Recommended for You',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: AppSpacing.edgeInsetsH16,
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

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (recommendation.type) {
      case RecommendationType.continueReading:
        icon = Icons.menu_book;
        color = Colors.blue;
        break;
      case RecommendationType.recentlyViewed:
        icon = Icons.history;
        color = Colors.orange;
        break;
      case RecommendationType.aiRecommended:
        icon = Icons.auto_awesome;
        color = Colors.purple;
        break;
      case RecommendationType.related:
        icon = Icons.link;
        color = Colors.teal;
        break;
      case RecommendationType.trendingInWorkspace:
        icon = Icons.trending_up;
        color = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            AppRoutes.documentViewer,
            pathParameters: {'id': recommendation.document.metadata.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: AppSpacing.edgeInsetsAll12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  AppSpacing.h8,
                  Expanded(
                    child: Text(
                      _getTypeLabel(recommendation.type),
                      style: context.textTheme.labelSmall?.copyWith(color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.v8,
              Text(
                recommendation.document.metadata.fileName,
                style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                recommendation.explanation,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.continueReading: return 'Continue Reading';
      case RecommendationType.recentlyViewed: return 'Recently Viewed';
      case RecommendationType.aiRecommended: return 'AI Recommended';
      case RecommendationType.related: return 'Related Content';
      case RecommendationType.trendingInWorkspace: return 'Trending';
    }
  }
}
