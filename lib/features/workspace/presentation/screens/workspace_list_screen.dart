import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_loading.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/workspace.dart';
import '../viewmodels/workspace_list_viewmodel.dart';
import '../widgets/workspace_card.dart';
import '../widgets/edit_workspace_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';

class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key});

  void _showWorkspaceOptions(BuildContext context, WidgetRef ref, Workspace workspace) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename / Edit'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context, ref, workspace);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text('Delete Workspace', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context, ref, workspace);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Workspace workspace) {
    showDialog(
      context: context,
      builder: (ctx) => EditWorkspaceDialog(workspace: workspace),
    ).then((updatedWorkspace) {
      if (updatedWorkspace != null && updatedWorkspace is Workspace) {
        ref.read(workspaceListViewModelProvider.notifier).updateWorkspaceDetails(updatedWorkspace);
      }
    });
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Workspace workspace) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmationDialog(
        title: 'Delete Workspace',
        message: 'Are you sure you want to delete "${workspace.name}"? This will permanently remove all documents within it.',
        onConfirm: () {
          ref.read(workspaceListViewModelProvider.notifier).removeWorkspace(workspace.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(workspaceListViewModelProvider);
    final notifier = ref.read(workspaceListViewModelProvider.notifier);

    return Scaffold(
      appBar: AuraAppBar(
        title: 'Workspaces',
        actions: [
          if (stateAsync.hasValue && stateAsync.value != null) ...[
            IconButton(
              icon: Icon(stateAsync.value!.viewMode == WorkspaceViewMode.grid ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                final newMode = stateAsync.value!.viewMode == WorkspaceViewMode.grid 
                    ? WorkspaceViewMode.list 
                    : WorkspaceViewMode.grid;
                notifier.setViewMode(newMode);
              },
            ),
            PopupMenuButton<WorkspaceSortOption>(
              icon: const Icon(Icons.sort),
              onSelected: notifier.setSortOption,
              itemBuilder: (context) => const [
                PopupMenuItem(value: WorkspaceSortOption.date, child: Text('Sort by Date')),
                PopupMenuItem(value: WorkspaceSortOption.name, child: Text('Sort by Name')),
                PopupMenuItem(value: WorkspaceSortOption.size, child: Text('Sort by Size')),
              ],
            ),
          ],
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          if (state.workspaces.isEmpty) {
            return const AuraEmptyState(
              icon: Icons.folder_open,
              title: 'No workspaces yet',
              message: 'Create a workspace to start organizing your knowledge.',
            );
          }
          
          if (state.viewMode == WorkspaceViewMode.list) {
            return ListView.separated(
              padding: AppSpacing.edgeInsetsAll16,
              itemCount: state.workspaces.length,
              separatorBuilder: (_, __) => AppSpacing.v12,
              itemBuilder: (context, index) {
                final workspace = state.workspaces[index];
                return WorkspaceCard(
                  workspace: workspace,
                  isListMode: true,
                  onTap: () => context.pushNamed(
                    AppRoutes.workspaceDetail,
                    pathParameters: {'id': workspace.id},
                  ),
                  onLongPress: () => _showWorkspaceOptions(context, ref, workspace),
                );
              },
            );
          }

          // Grid View
          return GridView.builder(
            padding: AppSpacing.edgeInsetsAll16,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: state.workspaces.length,
            itemBuilder: (context, index) {
              final workspace = state.workspaces[index];
              return WorkspaceCard(
                workspace: workspace,
                isListMode: false,
                onTap: () => context.pushNamed(
                  AppRoutes.workspaceDetail,
                  pathParameters: {'id': workspace.id},
                ),
                onLongPress: () => _showWorkspaceOptions(context, ref, workspace),
              );
            },
          );
        },
        loading: () => const AuraLoading(),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.createWorkspace),
        child: const Icon(Icons.add),
      ),
    );
  }
}
