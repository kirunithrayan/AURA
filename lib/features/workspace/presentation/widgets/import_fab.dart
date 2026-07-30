import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class ImportFab extends StatelessWidget {

  const ImportFab({
    super.key,
    required this.onImport,
  });
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
      onPressed: onImport,
      icon: const Icon(Icons.add),
      label: const Text('Import'),
      backgroundColor: context.theme.colorScheme.primaryContainer,
      foregroundColor: context.theme.colorScheme.onPrimaryContainer,
    );
}
