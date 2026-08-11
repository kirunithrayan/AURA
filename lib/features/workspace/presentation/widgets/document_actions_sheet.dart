import 'package:flutter/material.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/widgets/aura_button.dart';
import '../../../../core/widgets/aura_sheet.dart';

/// The per-document action surface opened from a document tile's overflow
/// control.
///
/// Composed at the screen layer from committed components; it introduces no new
/// component and no new action. Pin/unpin is the only action: the Design System
/// defers AI Insights from v1.0, so the legacy inline insights action is gone.
Future<void> showDocumentActionsSheet({
  required BuildContext context,
  required String fileName,
  required bool isPinned,
  required VoidCallback onTogglePin,
}) =>
    AuraSheet.show<void>(
      context: context,
      title: fileName,
      variant: AuraSheetVariant.metadata,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AuraSpacing.componentGap),
        child: AuraButton(
          label: isPinned ? 'Unpin' : 'Pin',
          variant: AuraButtonVariant.text,
          icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          onPressed: () {
            Navigator.of(context).pop();
            onTogglePin();
          },
        ),
      ),
    );
