import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_card.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const DashboardStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Workspaces',
          value: stats.totalWorkspaces.toString(),
          icon: Icons.folder,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Documents',
          value: stats.totalDocuments.toString(),
          icon: Icons.description,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Storage Used',
          value: SizeFormatter.formatBytes(stats.totalStorageUsed),
          icon: Icons.storage,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
