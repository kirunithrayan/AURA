import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/workspace_list_viewmodel.dart';
import '../widgets/workspace_icon_picker.dart';

class CreateWorkspaceScreen extends ConsumerStatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  ConsumerState<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends ConsumerState<CreateWorkspaceScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedIcon = 'folder';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workspace name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await ref
          .read(workspaceListViewModelProvider.notifier)
          .addWorkspace(
            name: name,
            description: _descController.text.trim(),
            icon: _selectedIcon,
          );

      if (mounted) {
        if (success) {
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create workspace')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AuraAppBar(
        title: 'New Workspace',
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _handleSave,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            AppSpacing.v16,
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            AppSpacing.v24,
            WorkspaceIconPicker(
              selectedIcon: _selectedIcon,
              onIconSelected: (icon) {
                setState(() => _selectedIcon = icon);
              },
            ),
          ],
        ),
      ),
    );
}
