import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/file_icon_widget.dart';
import '../../domain/entities/workspace_file.dart';

class FileGridTile extends StatelessWidget {
  final WorkspaceFile file;
  final VoidCallback onTap;

  const FileGridTile({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: context.theme.colorScheme.surfaceVariant.withOpacity(0.5),
              child: _buildPreview(context),
            ),
          ),
          Padding(
            padding: AppSpacing.edgeInsetsAll8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.v4,
                Text(
                  file.extension?.toUpperCase() ?? 'FILE',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (file.thumbnailPath != null && File(file.thumbnailPath!).existsSync()) {
      return Image.file(
        File(file.thumbnailPath!),
        fit: BoxFit.cover,
      );
    }
    return Center(
      child: FileIconWidget(
        extension: file.extension ?? '',
        size: 48,
      ),
    );
  }
}
