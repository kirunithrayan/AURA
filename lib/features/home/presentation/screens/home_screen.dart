import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_loading.dart';
import '../../../../core/widgets/aura_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/size_formatter.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../workspace/presentation/widgets/pinned_documents_section.dart';
import '../../../workspace/presentation/widgets/file_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AuraAppBar(
        title: 'AURA',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
        child: stateAsync.when(
          data: (state) {
            final stats = state.stats;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.edgeInsetsAll16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quick Actions
                        _buildQuickActions(context),
                        AppSpacing.v24,
                        
                        // Overview Stats
                        if (stats != null) _buildOverviewStats(context, stats),
                        AppSpacing.v24,
                      ],
                    ),
                  ),
                ),
                
                // Global Pinned Documents
                if (state.pinnedDocuments.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PinnedDocumentsSection(
                      files: state.pinnedDocuments,
                      onFileTap: (file) => context.pushNamed(
                        AppRoutes.documentViewer,
                        pathParameters: {'id': file.id},
                      ),
                      onUnpin: (file) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unpin documents directly from their Workspace.')),
                        );
                      },
                    ),
                  ),
                
                // Recent Documents
                if (state.recentDocuments.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppSpacing.edgeInsetsH16V8,
                      child: Text(
                        'Recent Documents',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: AppSpacing.edgeInsetsH16,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final file = state.recentDocuments[index];
                          return FileListTile(
                            file: file,
                            onTap: () => context.pushNamed(
                              AppRoutes.documentViewer,
                              pathParameters: {'id': file.id},
                            ),
                            onInsights: () => context.pushNamed(
                              AppRoutes.aiInsights,
                              pathParameters: {'id': file.id},
                            ),
                          );
                        },
                        childCount: state.recentDocuments.length,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 80)), // FAB padding
              ],
            );
          },
          loading: () => const AuraLoading(),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.workspaces),
        child: const Icon(Icons.folder_open),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.v16,
        Row(
          children: [
            Expanded(
              child: AuraCard(
                onTap: () => context.pushNamed(AppRoutes.createWorkspace),
                color: context.theme.colorScheme.primaryContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.create_new_folder, color: context.theme.colorScheme.onPrimaryContainer),
                    AppSpacing.v8,
                    Text('New Workspace', style: TextStyle(color: context.theme.colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
            ),
            AppSpacing.h16,
            Expanded(
              child: AuraCard(
                onTap: () => context.pushNamed(AppRoutes.search),
                color: context.theme.colorScheme.secondaryContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, color: context.theme.colorScheme.onSecondaryContainer),
                    AppSpacing.v8,
                    Text('Global Search', style: TextStyle(color: context.theme.colorScheme.onSecondaryContainer)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildOverviewStats(BuildContext context, dynamic stats) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.v16,
        Row(
          children: [
            Expanded(
              child: AuraCard(
                padding: AppSpacing.edgeInsetsAll12,
                child: Column(
                  children: [
                    Text('${stats.totalWorkspaces}', style: context.textTheme.headlineMedium),
                    Text('Workspaces', style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            AppSpacing.h12,
            Expanded(
              child: AuraCard(
                padding: AppSpacing.edgeInsetsAll12,
                child: Column(
                  children: [
                    Text('${stats.totalDocuments}', style: context.textTheme.headlineMedium),
                    Text('Documents', style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            AppSpacing.h12,
            Expanded(
              child: AuraCard(
                padding: AppSpacing.edgeInsetsAll12,
                child: Column(
                  children: [
                    Text(SizeFormatter.formatBytes(stats.totalStorageUsed).split(' ')[0], style: context.textTheme.headlineMedium),
                    Text('Storage', style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
}
