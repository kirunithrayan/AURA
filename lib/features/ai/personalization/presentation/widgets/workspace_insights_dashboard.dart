import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../viewmodels/workspace_insights_viewmodel.dart';

class WorkspaceInsightsDashboard extends ConsumerWidget {

  const WorkspaceInsightsDashboard({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(workspaceInsightsProvider(workspaceId));

    return insightsAsync.when(
      data: (insight) {
        if (insight.documentCount == 0 && insight.knowledgeNodeCount == 0) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.edgeInsetsH16.copyWith(top: 16, bottom: 8),
              child: Text(
                'Workspace Insights',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.edgeInsetsH16,
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.access_time,
                      title: 'Avg. Reading Time',
                      value: '${(insight.averageReadingTime / 60000).ceil()}m',
                    ),
                  ),
                  AppSpacing.h8,
                  Expanded(
                    child: _StatCard(
                      icon: Icons.hub,
                      title: 'Knowledge Nodes',
                      value: '${insight.knowledgeNodeCount}',
                    ),
                  ),
                  AppSpacing.h8,
                  Expanded(
                    child: _StatCard(
                      icon: Icons.forum,
                      title: 'Conversations',
                      value: '${insight.conversationCount}',
                    ),
                  ),
                ],
              ),
            ),
            if (insight.mostStudiedConcepts.isNotEmpty) ...[
              AppSpacing.v16,
              Padding(
                padding: AppSpacing.edgeInsetsH16,
                child: Text(
                  'Top Concepts',
                  style: context.textTheme.titleSmall,
                ),
              ),
              AppSpacing.v8,
              Padding(
                padding: AppSpacing.edgeInsetsH16,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: insight.mostStudiedConcepts.map((concept) => Chip(
                      label: Text(concept, style: const TextStyle(fontSize: 12)),
                      backgroundColor: context.theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(color: context.theme.colorScheme.onPrimaryContainer),
                    )).toList(),
                ),
              ),
            ]
          ],
        );
      },
      loading: () => const Padding(
        padding: AppSpacing.edgeInsetsAll16,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: AppSpacing.edgeInsetsAll12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: context.theme.colorScheme.primary),
            AppSpacing.v8,
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
}
