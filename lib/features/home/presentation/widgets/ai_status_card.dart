import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

class AiStatusCard extends StatelessWidget {
  final bool isSchedulerActive;
  final int pendingJobs;
  final int recentlyProcessed;

  const AiStatusCard({
    super.key,
    required this.isSchedulerActive,
    required this.pendingJobs,
    required this.recentlyProcessed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: AppSpacing.edgeInsetsAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSchedulerActive ? Icons.auto_awesome : Icons.pause_circle_outline,
                color: isSchedulerActive 
                    ? context.theme.colorScheme.primary 
                    : context.theme.colorScheme.outline,
              ),
              AppSpacing.h8,
              Text(
                isSchedulerActive ? 'Adaptive AI Active' : 'AI Processing Paused',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(context, pendingJobs.toString(), 'Pending Jobs'),
              _buildStat(context, recentlyProcessed.toString(), 'Processed Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
