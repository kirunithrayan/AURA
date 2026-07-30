import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_loading.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/diagnostics_viewmodel.dart';

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticsViewModelProvider);
    final viewModel = ref.read(diagnosticsViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AuraAppBar(
        title: 'Performance Diagnostics',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Metrics',
            onPressed: viewModel.loadDiagnostics,
          ),
        ],
      ),
      body: state.isLoading
          ? const AuraLoading()
          : state.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: AppSpacing.edgeInsetsAll16,
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: AppSpacing.edgeInsetsAll16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(theme),
                      AppSpacing.v16,
                      Text(
                        'Database & Search Metrics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.v8,
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildMetricTile(
                            theme,
                            icon: Icons.description,
                            label: 'Documents Indexed',
                            value: '${state.documentsIndexed}',
                            color: Colors.blueAccent,
                          ),
                          _buildMetricTile(
                            theme,
                            icon: Icons.grain,
                            label: 'Embedding Chunks',
                            value: '${state.embeddingCount}',
                            color: Colors.purpleAccent,
                          ),
                          _buildMetricTile(
                            theme,
                            icon: Icons.search_rounded,
                            label: 'Avg Search Time',
                            value: '${state.averageSearchTime.inMilliseconds} ms',
                            color: Colors.tealAccent,
                          ),
                          _buildMetricTile(
                            theme,
                            icon: Icons.speed,
                            label: 'Avg Indexing Time',
                            value: '${state.averageIndexingTime.inMilliseconds} ms',
                            color: Colors.amberAccent,
                          ),
                        ],
                      ),
                      AppSpacing.v16,
                      Text(
                        'Cache Performance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.v8,
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              theme,
                              icon: Icons.check_circle_outline,
                              label: 'Cache Hits',
                              value: '${state.cacheHits}',
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              theme,
                              icon: Icons.highlight_off,
                              label: 'Cache Misses',
                              value: '${state.cacheMisses}',
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.v16,
                      Text(
                        'Knowledge Graph & Storage',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.v8,
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildMetricTile(
                            theme,
                            icon: Icons.bubble_chart,
                            label: 'Knowledge Nodes',
                            value: '${state.knowledgeNodes}',
                            color: Colors.indigoAccent,
                          ),
                          _buildMetricTile(
                            theme,
                            icon: Icons.hub,
                            label: 'Knowledge Edges',
                            value: '${state.knowledgeEdges}',
                            color: Colors.deepOrangeAccent,
                          ),
                          _buildMetricTile(
                            theme,
                            icon: Icons.storage,
                            label: 'Database Size',
                            value: _formatBytes(state.databaseSizeBytes),
                            color: Colors.cyanAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) => Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: AppSpacing.edgeInsetsAll16,
        child: Row(
          children: [
            Icon(
              Icons.developer_mode,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            AppSpacing.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Live system runtime, index & storage diagnostics for evaluator verification.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildMetricTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Container(
      padding: AppSpacing.edgeInsetsAll12,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
