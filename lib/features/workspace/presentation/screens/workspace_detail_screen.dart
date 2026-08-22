import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_button.dart';
import '../../../../core/widgets/aura_document_tile.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../../core/widgets/aura_icon_button.dart';
import '../../../../core/widgets/aura_loading.dart';
import '../../../../core/widgets/aura_section_header.dart';
import '../../../../core/widgets/aura_sheet.dart';
import '../../domain/entities/workspace_file.dart';
import '../viewmodels/workspace_detail_viewmodel.dart';
import '../widgets/document_actions_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../../../ai/personalization/presentation/widgets/recommendations_section.dart';
import '../../../home/presentation/adapters/library_adapters.dart';

/// The Course screen.
///
/// Composition order is preserved from the pre-migration screen:
/// header/description, Pinned, Recommendations, Documents.
class WorkspaceDetailScreen extends ConsumerWidget {

  const WorkspaceDetailScreen({
    super.key,
    required this.workspaceId,
  });
  final String workspaceId;

  Future<void> _openSortSheet(
    BuildContext context,
    WorkspaceDetailViewModel notifier,
  ) =>
      AuraSheet.show<void>(
        context: context,
        title: 'Sort documents',
        variant: AuraSheetVariant.sort,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AuraSpacing.componentGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final (DocumentSortOption option, String label) in const <(
                DocumentSortOption,
                String
              )>[
                (DocumentSortOption.date, 'Sort by Date'),
                (DocumentSortOption.name, 'Sort by Name'),
                (DocumentSortOption.size, 'Sort by Size'),
              ])
                AuraButton(
                  label: label,
                  variant: AuraButtonVariant.text,
                  onPressed: () {
                    Navigator.of(context).pop();
                    notifier.setSortOption(option);
                  },
                ),
            ],
          ),
        ),
      );

  // Single-document deletion. Unlike workspace deletion (which pops back to the
  // library), this keeps the workspace screen open — the ViewModel re-fetches so
  // the tile disappears in place.
  Future<void> _confirmDocumentDelete(
    BuildContext context,
    WorkspaceDetailViewModel notifier,
    WorkspaceFile file,
  ) =>
      showDialog<void>(
        context: context,
        builder: (_) => DeleteConfirmationDialog(
          title: 'Delete document?',
          message: "This permanently deletes '${file.fileName}'. "
              'This cannot be undone.',
          onConfirm: () => _performDocumentDelete(context, notifier, file),
        ),
      );

  Future<void> _performDocumentDelete(
    BuildContext context,
    WorkspaceDetailViewModel notifier,
    WorkspaceFile file,
  ) async {
    try {
      await notifier.removeFile(file.id);
      if (!context.mounted) return;
      context.showSnackBar("'${file.fileName}' deleted.");
    } catch (_) {
      if (!context.mounted) return;
      context.showSnackBar('Failed to delete document. Please try again.', isError: true);
    }
  }

  Widget _documentTile(
    BuildContext context,
    WorkspaceDetailViewModel notifier,
    WorkspaceFile file, {
    required bool isPinned,
  }) =>
      AuraDocumentTile(
        title: file.fileName,
        fileType: auraFileTypeForExtension(file.extension),
        onTap: () => context.pushNamed(
          AppRoutes.documentViewer,
          pathParameters: <String, String>{'id': file.id},
        ),
        onMoreActions: () => showDocumentActionsSheet(
          context: context,
          fileName: file.fileName,
          isPinned: isPinned,
          onTogglePin: () => isPinned
              ? notifier.unpinFile(file.id)
              : notifier.pinFile(file.id),
          onDelete: () => _confirmDocumentDelete(context, notifier, file),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(workspaceDetailViewModelProvider(workspaceId));
    final notifier = ref.read(workspaceDetailViewModelProvider(workspaceId).notifier);

    return Scaffold(
      appBar: AuraAppBar(
        variant: AuraAppBarVariant.nested,
        title: stateAsync.value?.workspace?.name ?? 'Workspace',
        actions: <Widget>[
          AuraIconButton(
            icon: Icons.auto_awesome,
            tooltip: 'Ask AURA',
            onPressed: () => context.pushNamed(
              AppRoutes.askAura,
              pathParameters: <String, String>{'workspaceId': workspaceId},
            ),
          ),
          if (stateAsync.hasValue && stateAsync.value != null && stateAsync.value!.allFiles.isNotEmpty)
            AuraIconButton(
              icon: Icons.sort,
              tooltip: 'Sort documents',
              onPressed: () => _openSortSheet(context, notifier),
            ),
          AuraIconButton(
            icon: Icons.add,
            tooltip: 'Import documents',
            onPressed: notifier.importFiles,
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
                    padding: const EdgeInsets.all(AuraSpacing.screenMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.workspace!.description != null && state.workspace!.description!.isNotEmpty) ...[
                          Text(
                            state.workspace!.description!,
                            style: AuraTypography.body.copyWith(
                              color: context.tokens.colors.contentSecondary,
                            ),
                          ),
                          const SizedBox(height: AuraSpacing.gapTight),
                        ],
                        Text(
                          'Created ${DateFormatter.timeAgo(state.workspace!.createdAt)}',
                          style: AuraTypography.caption.copyWith(
                            color: context.tokens.colors.contentTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (hasNoDocuments)
                const SliverFillRemaining(
                  child: AuraEmptyState(
                    title: 'Course is empty',
                    message: 'Use Import to add documents to this course.',
                  ),
                )
              else ...[
                // Pinned Documents
                if (state.pinnedFiles.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.screenMargin,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return const Padding(
                              padding: EdgeInsets.only(
                                bottom: AuraSpacing.componentGap,
                              ),
                              child: AuraSectionHeader(title: 'Pinned'),
                            );
                          }
                          final file = state.pinnedFiles[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AuraSpacing.componentGap,
                            ),
                            child: _documentTile(
                              context,
                              notifier,
                              file,
                              isPinned: true,
                            ),
                          );
                        },
                        childCount: state.pinnedFiles.length + 1,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: RecommendationsSection(workspaceId: workspaceId),
                ),

                // Documents
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AuraSpacing.screenMargin,
                      AuraSpacing.sectionGap,
                      AuraSpacing.screenMargin,
                      AuraSpacing.componentGap,
                    ),
                    child: AuraSectionHeader(title: 'Documents'),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuraSpacing.screenMargin,
                  ).copyWith(bottom: AuraSpacing.s64),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final file = state.allFiles[index];
                        final isPinned = state.pinnedFiles.any((pf) => pf.id == file.id);

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AuraSpacing.componentGap,
                          ),
                          child: _documentTile(
                            context,
                            notifier,
                            file,
                            isPinned: isPinned,
                          ),
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
    );
  }
}
