import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// Sheet variants. Declared for the Design System's variant-based sheet model;
/// they carry no bespoke behavior yet (deferred), so no fake functionality is
/// implied. Names are an implementation proposal.
enum AuraSheetVariant { standard, sort, settings, metadata }

/// The AURA bottom sheet for secondary flows.
///
/// One variant-based abstraction over [showModalBottomSheet], which supplies
/// the required overlay behavior: focus moves into the sheet, returns to the
/// trigger on dismissal, the background becomes inert, and system-back
/// dismisses. Sheets are single-level; stacking is not supported.
class AuraSheet {
  const AuraSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    AuraSheetVariant variant = AuraSheetVariant.standard,
    bool isScrollControlled = true,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) =>
            _AuraSheetSurface(title: title, child: child),
      );
}

class _AuraSheetSurface extends StatelessWidget {
  const _AuraSheetSurface({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final String? sheetTitle = title;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AuraRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AuraSpacing.componentPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: AuraSpacing.s32,
                  height: AuraSpacing.gapMicro,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(AuraRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AuraSpacing.componentGap),
              if (sheetTitle != null) ...<Widget>[
                Text(
                  sheetTitle,
                  style: AuraTypography.titleMd.copyWith(
                    color: colors.contentPrimary,
                  ),
                ),
                const SizedBox(height: AuraSpacing.componentGap),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
