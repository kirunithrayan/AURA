import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// A utility to show standard styled bottom sheets in AURA.
///
/// Design System: sheets use the overlay surface with `radius.lg` top corners.
class AuraBottomSheet {
  AuraBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => Container(
          decoration: BoxDecoration(
            color: ctx.tokens.colors.surfaceOverlay,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AuraRadius.lg),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AuraSpacing.s12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.tokens.colors.divider,
                  borderRadius: BorderRadius.circular(AuraRadius.full),
                ),
              ),
              const SizedBox(height: AuraSpacing.s16),
              Flexible(child: builder(ctx)),
            ],
          ),
        ),
    );
}
