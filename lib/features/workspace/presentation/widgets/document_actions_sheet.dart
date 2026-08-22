import 'package:flutter/material.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/widgets/aura_button.dart';
import '../../../../core/widgets/aura_sheet.dart';

/// The per-document action surface opened from a document tile's overflow
/// control.
///
/// Composed at the screen layer from committed components; it introduces no new
/// component. The Design System defers AI Insights from v1.0, so the legacy
/// inline insights action is gone. Two actions remain: Pin/unpin, and a
/// destructive Delete that closes the sheet and hands off to [onDelete] (which
/// the screen wires to the delete-confirmation flow).
Future<void> showDocumentActionsSheet({
  required BuildContext context,
  required String fileName,
  required bool isPinned,
  required VoidCallback onTogglePin,
  required VoidCallback onDelete,
}) =>
    AuraSheet.show<void>(
      context: context,
      title: fileName,
      variant: AuraSheetVariant.metadata,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AuraSpacing.componentGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AuraButton(
              label: isPinned ? 'Unpin' : 'Pin',
              variant: AuraButtonVariant.text,
              icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              onPressed: () {
                Navigator.of(context).pop();
                onTogglePin();
              },
            ),
            AuraButton(
              label: 'Delete',
              variant: AuraButtonVariant.text,
              icon: Icons.delete_outline,
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
