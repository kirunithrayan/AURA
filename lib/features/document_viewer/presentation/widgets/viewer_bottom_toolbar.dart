import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/design_system/design_tokens.dart';
import 'package:aura/core/extensions/context_extensions.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import 'viewers/pdf/jump_to_page_dialog.dart';

/// Reader bottom chrome, restyled to design tokens in Step 8.
///
/// Controls, capabilities, page navigation, zoom, rotate and the jump-to-page
/// dialog are unchanged; only colors, typography and metrics now resolve
/// through the token layer.
class ViewerBottomToolbar extends ConsumerWidget {

  const ViewerBottomToolbar({
    super.key,
    required this.file,
    required this.capabilities,
    required this.actionRegistry,
  });
  final WorkspaceFile file;
  final Set<ViewerCapability> capabilities;
  final ViewerActionRegistry actionRegistry;

  void _execute(WidgetRef ref, BuildContext context, ViewerCapability cap, [dynamic payload]) {
    actionRegistry.getCommand(cap)?.execute(
      ref.read(documentViewerViewModelProvider(file.id).notifier),
      payload ?? context,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuraColors colors = context.tokens.colors;
    final state = ref.watch(documentViewerViewModelProvider(file.id)).valueOrNull;
    if (state == null) return const SizedBox.shrink();

    final List<Widget> controls = [];

    Widget icon(IconData data) => Icon(data, size: AuraIconTokens.sizeMd);

    if (capabilities.contains(ViewerCapability.pageNavigation)) {
      controls.add(IconButton(
        icon: icon(Icons.arrow_upward),
        color: colors.contentSecondary,
        disabledColor: colors.contentDisabled,
        onPressed: state.viewState.currentPage > 1
            ? () => _execute(ref, context, ViewerCapability.pageNavigation, 'prev')
            : null,
      ));
      controls.add(
        InkWell(
          onTap: () async {
            final page = await showDialog<int>(
              context: context,
              builder: (ctx) => JumpToPageDialog(
                currentPage: state.viewState.currentPage,
                pageCount: state.viewState.pageCount,
              ),
            );
            if (page != null && context.mounted) {
              _execute(ref, context, ViewerCapability.pageNavigation, page);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AuraSpacing.componentGap,
              vertical: AuraSpacing.gapTight,
            ),
            child: Text(
              '${state.viewState.currentPage} / ${state.viewState.pageCount}',
              style: AuraTypography.label.copyWith(color: colors.contentPrimary),
            ),
          ),
        ),
      );
      controls.add(IconButton(
        icon: icon(Icons.arrow_downward),
        color: colors.contentSecondary,
        disabledColor: colors.contentDisabled,
        onPressed: state.viewState.currentPage < state.viewState.pageCount
            ? () => _execute(ref, context, ViewerCapability.pageNavigation, 'next')
            : null,
      ));
    }

    if (capabilities.contains(ViewerCapability.zoom)) {
      controls.add(IconButton(
        icon: icon(Icons.remove_circle_outline),
        color: colors.contentSecondary,
        onPressed: () => _execute(ref, context, ViewerCapability.zoom, 'out'),
      ));
      controls.add(IconButton(
        icon: icon(Icons.add_circle_outline),
        color: colors.contentSecondary,
        onPressed: () => _execute(ref, context, ViewerCapability.zoom, 'in'),
      ));
    }

    if (capabilities.contains(ViewerCapability.rotate)) {
      controls.add(IconButton(
        icon: icon(Icons.rotate_left),
        color: colors.contentSecondary,
        onPressed: () => _execute(ref, context, ViewerCapability.rotate, 'left'),
      ));
      controls.add(IconButton(
        icon: icon(Icons.rotate_right),
        color: colors.contentSecondary,
        onPressed: () => _execute(ref, context, ViewerCapability.rotate, 'right'),
      ));
    }

    if (capabilities.contains(ViewerCapability.textSettings)) {
      controls.add(IconButton(
        icon: icon(Icons.text_format),
        color: colors.contentSecondary,
        onPressed: () => _execute(ref, context, ViewerCapability.textSettings),
      ));
    }

    if (controls.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.componentPadding,
        vertical: AuraSpacing.gapTight,
      ),
      decoration: BoxDecoration(
        // DESIGN-SYSTEM-GAP: this bar has always been ~90% opaque, and the
        // token system has no opacity role above `disabled` (0.38), so the
        // alpha cannot be expressed through a token. The blueprint does not
        // state that reader chrome must be opaque, so the existing behaviour is
        // preserved with a documented literal rather than silently changed.
        // Replace with a token when an approved surface-alpha role exists.
        color: colors.surfaceRaised.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: colors.divider,
            width: AuraBorders.hairline,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: controls,
        ),
      ),
    );
  }
}
