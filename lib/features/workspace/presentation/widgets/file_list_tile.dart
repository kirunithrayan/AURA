import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../core/widgets/file_icon_widget.dart';
import '../../domain/entities/workspace_file.dart';

class FileListTile extends StatelessWidget {

  const FileListTile({
    super.key,
    required this.file,
    required this.onTap,
    this.isPinned = false,
    this.onPinToggle,
    this.onPin,
    this.onInsights,
  });
  final WorkspaceFile file;
  final VoidCallback onTap;
  final bool isPinned;
  final VoidCallback? onPinToggle;
  final VoidCallback? onPin;
  final VoidCallback? onInsights;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(file.createdAt);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: FileIconWidget(
          extension: file.extension ?? '',
          size: 24,
        ),
      ),
      title: Text(
        file.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${date.toRelativeString()} • ${SizeFormatter.formatBytes(file.size ?? 0)}',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onInsights != null)
            IconButton(
              icon: const Icon(Icons.insights),
              tooltip: 'AI Insights',
              onPressed: onInsights,
            ),
          IconButton(
            icon: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: isPinned ? context.theme.colorScheme.primary : null,
            ),
            onPressed: onPinToggle ?? onPin,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
