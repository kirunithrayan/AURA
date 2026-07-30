import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// A standard loading indicator for AURA.
class AuraLoading extends StatelessWidget {

  const AuraLoading({
    super.key,
    this.message,
    this.compact = false,
  });
  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
