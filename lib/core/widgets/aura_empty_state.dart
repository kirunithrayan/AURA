import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

/// A standard empty state for lists or grids that have no data.
///
/// Design System: no illustrations. The [icon] parameter is deprecated and no
/// longer rendered; the contract is a title, an optional message, and an
/// optional single action.
class AuraEmptyState extends StatelessWidget {

  const AuraEmptyState({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.icon,
  });

  final String title;
  final String? message;
  final Widget? action;

  /// LEGACY: ignored and no longer rendered. AURA empty states carry no
  /// illustration. Kept for source compatibility.
  @Deprecated(
    'Design System empty states have no illustration. This value is ignored '
    'and no longer rendered. Kept for source compatibility.',
  )
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final String? bodyMessage = message;
    final Widget? actionWidget = action;
    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsAll24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            if (bodyMessage != null) ...<Widget>[
              AppSpacing.v8,
              Text(
                bodyMessage,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionWidget != null) ...<Widget>[
              AppSpacing.v24,
              actionWidget,
            ],
          ],
        ),
      ),
    );
  }
}
