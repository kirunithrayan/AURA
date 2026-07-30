import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_loading.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/router/app_routes.dart';
import '../viewmodels/workspace_detail_viewmodel.dart';
import '../widgets/pinned_documents_section.dart';
import '../widgets/file_list_tile.dart';
import '../widgets/import_fab.dart';
import '../../../ai/personalization/presentation/widgets/recommendations_section.dart';
import '../../../ai/personalization/presentation/widgets/workspace_insights_dashboard.dart';

class WorkspaceDetailScreen extends ConsumerWidget {

  const WorkspaceDetailScreen({
    super.key,
    required this.workspaceId,
  });
  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(workspaceDetailViewModelProvider(workspaceId));
    final notifier = ref.read(workspaceDetailViewModelProvider(workspaceId).notifier);

    return Scaffold(
      appBar: AuraAppBar(
        title: stateAsync.value?.workspace?.name ?? 'Workspace',
        actions: [
          IconButton(
            icon: const Icon(Icons.hub),
            tooltip: 'Knowledge Graph',
            onPressed: () => context.pushNamed(
              AppRoutes.knowledgeGraph,
              pathParameters: {'workspaceId': workspaceId},
            ),
          ),
          if (stateAsync.hasValue && stateAsync.value != null && stateAsync.value!.allFiles.isNotEmpty)
            PopupMenuButton<DocumentSortOption>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort Documents',
              onSelected: notifier.setSortOption,
              itemBuilder: (context) => const [
                PopupMenuItem(value: DocumentSortOption.date, child: Text('Sort by Date')),
                PopupMenuItem(value: DocumentSortOption.name, child: Text('Sort by Name')),
                PopupMenuItem(value: DocumentSortOption.size, child: Text('Sort by Size')),
              ],
            ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          final hasNoDocuments = state.allFiles.isEmpty && state.pinnedFiles.isEmpty;

          return CustomScrollView(
            slivers: [
              // Workspace Header / Information
              if (state.workspace != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.edgeInsetsAll16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.workspace!.description != null && state.workspace!.description!.isNotEmpty) ...[
                          Text(
                            state.workspace!.description!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.v8,
                        ],
                        Text(
                          'Created ${DateFormatter.timeAgo(state.workspace!.createdAt)}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              if (hasNoDocuments)
                const SliverFillRemaining(
                  child: AuraEmptyState(
                    icon: Icons.note_add,
                    title: 'Workspace is empty',
                    message: 'Tap the + button to import documents into this workspace.',
                  ),
                )
              else ...[
                // Pinned Documents Section
                if (state.pinnedFiles.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PinnedDocumentsSection(
                      files: state.pinnedFiles,
                      onFileTap: (file) => context.pushNamed(
                        AppRoutes.documentViewer,
                        pathParameters: {'id': file.id},
                      ),
                      onUnpin: (file) => notifier.unpinFile(file.id),
                    ),
                  ),
                
                SliverToBoxAdapter(
                  child: RecommendationsSection(workspaceId: workspaceId),
                ),
                SliverToBoxAdapter(
                  child: WorkspaceInsightsDashboard(workspaceId: workspaceId),
                ),
                
                // All Documents Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.edgeInsetsAll16,
                    child: Text(
                      'All Documents (${state.allFiles.length})',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // All Documents List
                SliverPadding(
                  padding: AppSpacing.edgeInsetsH16.copyWith(bottom: 80), // Padding for FAB
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final file = state.allFiles[index];
                        final isPinned = state.pinnedFiles.any((pf) => pf.id == file.id);
                        
                        return FileListTile(
                          file: file,
                          onTap: () => context.pushNamed(
                            AppRoutes.documentViewer,
                            pathParameters: {'id': file.id},
                          ),
                          onPin: isPinned 
                              ? () => notifier.unpinFile(file.id)
                              : () => notifier.pinFile(file.id),
                        );
                      },
                      childCount: state.allFiles.length,
                    ),
                  ),
                ),
              ]
            ],
          );
        },
        loading: () => const AuraLoading(),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: ImportFab(
        onImport: notifier.importFiles,
      ),
    );
  }
}
