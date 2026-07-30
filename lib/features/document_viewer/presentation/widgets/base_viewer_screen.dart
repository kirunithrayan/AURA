import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/aura_loading.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'viewer_toolbar.dart';
import 'viewer_bottom_toolbar.dart';
import 'shortcut_manager.dart';
import 'viewer_providers.dart';
import '../../domain/utils/viewer_capabilities_helper.dart';
import '../../core/utils/file_type_helper.dart';

class BaseViewerScreen extends ConsumerWidget {

  const BaseViewerScreen({
    super.key,
    required this.title,
    required this.child,
    this.isLoading = false,
    this.error,
    this.file,
    this.actions,
  });
  final String title;
  final Widget child;
  final bool isLoading;
  final String? error;
  final WorkspaceFile? file;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewerType = file != null ? FileTypeHelper.getViewerType(file!.extension) : null;
    final capabilities = viewerType?.capabilities ?? {};
    final actionRegistry = ref.watch(viewerActionRegistryProvider);

    Widget body = _buildBody();

    if (file != null) {
      body = ViewerShortcutManager(
        file: file!,
        capabilities: capabilities,
        actionRegistry: actionRegistry,
        child: body,
      );
    }

    return Scaffold(
      appBar: ViewerToolbar(
        file: file,
        capabilities: capabilities,
        actionRegistry: actionRegistry,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (file != null)
              ViewerBottomToolbar(
                file: file!,
                capabilities: capabilities,
                actionRegistry: actionRegistry,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const AuraLoading();
    }
    
    if (error != null) {
      return AuraEmptyState(
        icon: Icons.error_outline,
        title: 'Error Loading Document',
        message: error!,
      );
    }
    
    return child;
  }
}
