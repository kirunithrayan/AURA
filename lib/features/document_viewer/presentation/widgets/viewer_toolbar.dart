import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import 'viewer_action_menu.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';

class ViewerToolbar extends ConsumerWidget implements PreferredSizeWidget {
  final WorkspaceFile? file;
  final Set<ViewerCapability> capabilities;
  final ViewerActionRegistry actionRegistry;

  const ViewerToolbar({
    super.key,
    this.file,
    required this.capabilities,
    required this.actionRegistry,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = file?.fileName ?? 'Document';
    final subtitle = file?.extension?.toUpperCase() ?? '';

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
      actions: _buildActions(context, ref),
    );
  }

  List<Widget> _buildActions(BuildContext context, WidgetRef ref) {
    if (file == null) return [];
    
    final state = ref.watch(documentViewerViewModelProvider(file!.id)).valueOrNull;
    if (state == null) return [];

    final actions = <Widget>[];

    void executeCommand(ViewerCapability cap) {
      actionRegistry.getCommand(cap)?.execute(
        ref.read(documentViewerViewModelProvider(file!.id).notifier), 
        context,
      );
    }

    if (capabilities.contains(ViewerCapability.share)) {
      actions.add(IconButton(
        icon: const Icon(Icons.share),
        tooltip: 'Share document',
        onPressed: () => executeCommand(ViewerCapability.share),
      ));
    }

    if (capabilities.contains(ViewerCapability.metadata)) {
      actions.add(IconButton(
        icon: const Icon(Icons.info_outline),
        tooltip: 'View document metadata',
        onPressed: () => executeCommand(ViewerCapability.metadata),
      ));
    }

    actions.add(ViewerActionMenu(
      actionRegistry: actionRegistry,
      capabilities: capabilities,
      state: state,
    ));

    return actions;
  }
}
