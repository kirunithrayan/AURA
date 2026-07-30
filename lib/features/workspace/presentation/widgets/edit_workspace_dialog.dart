import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/workspace.dart';

/// Dialog to edit workspace details (name and description).
class EditWorkspaceDialog extends StatefulWidget {
  
  const EditWorkspaceDialog({super.key, required this.workspace});
  final Workspace workspace;

  @override
  State<EditWorkspaceDialog> createState() => _EditWorkspaceDialogState();
}

class _EditWorkspaceDialogState extends State<EditWorkspaceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace.name);
    _descController = TextEditingController(text: widget.workspace.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('Edit Workspace'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacing.v16,
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // Trigger actual update logic here
            context.pop(
              widget.workspace.copyWith(
                name: _nameController.text.trim(),
                description: _descController.text.trim(),
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
}
