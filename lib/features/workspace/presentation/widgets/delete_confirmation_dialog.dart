import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A reusable confirmation dialog for destructive actions like deleting a workspace.
class DeleteConfirmationDialog extends StatelessWidget {

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });
  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            onConfirm();
            context.pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
}
