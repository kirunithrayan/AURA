import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import '../../../../core/utils/app_logger.dart';

class ViewerActionMenu extends ConsumerWidget {

  const ViewerActionMenu({
    super.key,
    required this.actionRegistry,
    required this.capabilities,
    required this.state,
  });
  final ViewerActionRegistry actionRegistry;
  final Set<ViewerCapability> capabilities;
  final DocumentViewerViewModelState state;

  void _executeCommand(BuildContext context, WidgetRef ref, ViewerCapability capability) {
    final command = actionRegistry.getCommand(capability);
    if (command != null) {
      final notifier = ref.read(documentViewerViewModelProvider(state.file!.id).notifier);
      command.execute(notifier, context);
      AppLogger.info('ViewerActionMenu: Executed command for $capability');
    }
  }

  void _showDisabled(BuildContext context, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<ViewerCapability>(
      icon: const Icon(Icons.more_vert),
      onSelected: (capability) {
        _executeCommand(context, ref, capability);
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<ViewerCapability>> items = [];

        if (capabilities.contains(ViewerCapability.share)) {
          items.add(const PopupMenuItem(
            value: ViewerCapability.share,
            child: Text('Share'),
          ));
        }

        if (capabilities.contains(ViewerCapability.openExternally)) {
          items.add(const PopupMenuItem(
            value: ViewerCapability.openExternally,
            child: Text('Open Externally'),
          ));
        }

        if (capabilities.contains(ViewerCapability.copy)) {
          items.add(const PopupMenuItem(
            value: ViewerCapability.copy,
            child: Text('Copy File Path'),
          ));
        }

        if (capabilities.contains(ViewerCapability.metadata)) {
          items.add(const PopupMenuItem(
            value: ViewerCapability.metadata,
            child: Text('View Metadata'),
          ));
        }

        items.add(const PopupMenuDivider());

        items.add(PopupMenuItem(
          enabled: false,
          child: const Text('Add to Favorites (Coming soon)'),
          onTap: () => _showDisabled(context, 'Coming in a future update.'),
        ));
        items.add(PopupMenuItem(
          enabled: false,
          child: const Text('AI Insights (Coming soon)'),
          onTap: () => _showDisabled(context, 'Coming in a future update.'),
        ));
        items.add(PopupMenuItem(
          enabled: false,
          child: const Text('Compare (Coming soon)'),
          onTap: () => _showDisabled(context, 'Coming in a future update.'),
        ));

        return items;
      },
    );
}
