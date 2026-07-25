import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';
import 'viewers/pdf/jump_to_page_dialog.dart';

class ViewerBottomToolbar extends ConsumerWidget {
  final WorkspaceFile file;
  final Set<ViewerCapability> capabilities;
  final ViewerActionRegistry actionRegistry;

  const ViewerBottomToolbar({
    super.key,
    required this.file,
    required this.capabilities,
    required this.actionRegistry,
  });

  void _execute(WidgetRef ref, BuildContext context, ViewerCapability cap, [dynamic payload]) {
    actionRegistry.getCommand(cap)?.execute(
      ref.read(documentViewerViewModelProvider(file.id).notifier),
      payload ?? context,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentViewerViewModelProvider(file.id)).valueOrNull;
    if (state == null) return const SizedBox.shrink();

    final List<Widget> controls = [];

    if (capabilities.contains(ViewerCapability.pageNavigation)) {
      controls.add(IconButton(
        icon: const Icon(Icons.arrow_upward),
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
            if (page != null) {
              _execute(ref, context, ViewerCapability.pageNavigation, page);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('${state.viewState.currentPage} / ${state.viewState.pageCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      );
      controls.add(IconButton(
        icon: const Icon(Icons.arrow_downward),
        onPressed: state.viewState.currentPage < state.viewState.pageCount
            ? () => _execute(ref, context, ViewerCapability.pageNavigation, 'next')
            : null,
      ));
    }

    if (capabilities.contains(ViewerCapability.zoom)) {
      controls.add(IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () => _execute(ref, context, ViewerCapability.zoom, 'out'),
      ));
      controls.add(IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => _execute(ref, context, ViewerCapability.zoom, 'in'),
      ));
    }

    if (capabilities.contains(ViewerCapability.rotate)) {
      controls.add(IconButton(
        icon: const Icon(Icons.rotate_left),
        onPressed: () => _execute(ref, context, ViewerCapability.rotate, 'left'),
      ));
      controls.add(IconButton(
        icon: const Icon(Icons.rotate_right),
        onPressed: () => _execute(ref, context, ViewerCapability.rotate, 'right'),
      ));
    }

    if (capabilities.contains(ViewerCapability.textSettings)) {
      controls.add(IconButton(
        icon: const Icon(Icons.text_format),
        onPressed: () => _execute(ref, context, ViewerCapability.textSettings),
      ));
    }

    if (controls.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        border: Border(top: BorderSide(color: AppColors.divider)),
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
