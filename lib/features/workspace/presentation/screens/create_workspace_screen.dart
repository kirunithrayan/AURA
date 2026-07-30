import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/theme/app_spacing.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AuraAppBar(
        title: 'New Workspace',
        actions: [
          TextButton(
            onPressed: () {
              // Trigger save
            },
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
