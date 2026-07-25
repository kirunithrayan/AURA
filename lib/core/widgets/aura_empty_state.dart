import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

/// A standard empty state widget for lists or grids that have no data.
class AuraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const AuraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsAll24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: 64,
                color: context.theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            AppSpacing.v24,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            if (message != null) ...[
              AppSpacing.v8,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              AppSpacing.v24,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
