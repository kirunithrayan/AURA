import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/workspace_file.dart';
import 'file_list_tile.dart';

class PinnedDocumentsSection extends StatelessWidget {

  const PinnedDocumentsSection({
    super.key,
    required this.files,
    required this.onFileTap,
    required this.onUnpin,
  });
  final List<WorkspaceFile> files;
  final Function(WorkspaceFile) onFileTap;
  final Function(WorkspaceFile) onUnpin;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.edgeInsetsH16V8,
          child: Row(
            children: [
              Icon(Icons.push_pin, size: 18, color: context.theme.colorScheme.primary),
              AppSpacing.h8,
              Text(
                'Pinned Documents',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) => FileListTile(
              file: files[index],
              onTap: () => onFileTap(files[index]),
              isPinned: true,
              onPinToggle: () => onUnpin(files[index]),
            ),
        ),
        const Divider(),
      ],
    );
}
