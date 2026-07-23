import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/workspace.dart';

class WorkspaceCard extends StatelessWidget {
  final Workspace workspace;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isListMode;

  const WorkspaceCard({
    super.key,
    required this.workspace,
    required this.onTap,
    this.onLongPress,
    this.isListMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isListMode) {
      return AuraCard(
        onTap: onTap,
        onLongPress: onLongPress,
        padding: AppSpacing.edgeInsetsAll12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: workspace.color != null 
                    ? Color(workspace.color!).withOpacity(0.1) 
                    : context.theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.folder,
                color: workspace.color != null ? Color(workspace.color!) : context.theme.colorScheme.primary,
                size: 28,
              ),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          workspace.name,
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (workspace.isPinned)
                        Icon(Icons.push_pin, size: 16, color: context.theme.colorScheme.secondary),
                    ],
                  ),
                  AppSpacing.v4,
                  Text(
                    '${workspace.fileCount} files • ${SizeFormatter.formatBytes(workspace.totalSize)} • ${DateFormatter.timeAgo(workspace.createdAt)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Grid Mode
    return AuraCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.folder,
                color: workspace.color != null ? Color(workspace.color!) : context.theme.colorScheme.primary,
                size: 32,
              ),
              if (workspace.isPinned)
                Icon(Icons.push_pin, size: 16, color: context.theme.colorScheme.secondary),
            ],
          ),
          const Spacer(),
          Text(
            workspace.name,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.v4,
          Text(
            '${workspace.fileCount} files',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            DateFormatter.timeAgo(workspace.createdAt),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
