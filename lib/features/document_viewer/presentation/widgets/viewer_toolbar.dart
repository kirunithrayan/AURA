import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/design_system/design_tokens.dart';
import 'package:aura/core/extensions/context_extensions.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import 'viewer_action_menu.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';

/// Reader top chrome, restyled to design tokens in Step 8.
///
/// Structure, actions, capabilities and the action registry are unchanged; only
/// colors, typography and metrics now resolve through the token layer.
class ViewerToolbar extends ConsumerWidget implements PreferredSizeWidget {

  const ViewerToolbar({
    super.key,
    this.file,
    required this.capabilities,
    required this.actionRegistry,
  });
  final WorkspaceFile? file;
  final Set<ViewerCapability> capabilities;
  final ViewerActionRegistry actionRegistry;

  @override
  Size get preferredSize => const Size.fromHeight(AuraLayout.appBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuraColors colors = context.tokens.colors;
    final title = file?.fileName ?? 'Document';
    final subtitle = file?.extension?.toUpperCase() ?? '';

    return AppBar(
      backgroundColor: colors.surfaceRaised,
      foregroundColor: colors.contentSecondary,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AuraTypography.titleSm.copyWith(color: colors.contentPrimary),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: AuraTypography.caption
                  .copyWith(color: colors.contentSecondary),
            ),
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
        icon: const Icon(Icons.share, size: AuraIconTokens.sizeMd),
        tooltip: 'Share document',
        onPressed: () => executeCommand(ViewerCapability.share),
      ));
    }

    if (capabilities.contains(ViewerCapability.metadata)) {
      actions.add(IconButton(
        icon: const Icon(Icons.info_outline, size: AuraIconTokens.sizeMd),
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
