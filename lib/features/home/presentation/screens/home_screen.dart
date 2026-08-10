import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/aura_course_grid_section.dart';
import '../../../../core/widgets/aura_loading.dart';
import '../../../../core/widgets/aura_recent_section.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../../../workspace/presentation/viewmodels/workspace_list_viewmodel.dart';
import '../adapters/library_adapters.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/library_view.dart';

/// The Library: AURA's root screen.
///
/// Composes the Design System's course grid and recent documents from the
/// existing home and workspace-list providers. Presentation only — no new
/// provider, repository, or persistence is introduced here.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeState> homeAsync = ref.watch(homeViewModelProvider);
    final AsyncValue<WorkspaceListState> workspacesAsync =
        ref.watch(workspaceListViewModelProvider);

    final List<Workspace> workspaces =
        workspacesAsync.valueOrNull?.workspaces ?? const <Workspace>[];
    final List<WorkspaceFile> recentFiles =
        homeAsync.valueOrNull?.recentDocuments ?? const <WorkspaceFile>[];

    // Both sources are still loading and neither has data to show yet.
    if (homeAsync.isLoading && workspacesAsync.isLoading) {
      return const Scaffold(body: AuraLoading());
    }

    final Map<String, String> courseNamesById = <String, String>{
      for (final Workspace workspace in workspaces) workspace.id: workspace.name,
    };

    return LibraryView(
      courses: <AuraCourseData>[
        for (final Workspace workspace in workspaces)
          AuraCourseData(
            name: workspace.name,
            color: auraCourseColorForWorkspaceId(workspace.id),
            onTap: () => context.pushNamed(
              AppRoutes.workspaceDetail,
              pathParameters: <String, String>{'id': workspace.id},
            ),
          ),
      ],
      recentDocuments: <AuraRecentDocumentData>[
        for (final WorkspaceFile file in recentFiles)
          AuraRecentDocumentData(
            title: file.fileName,
            subtitle: courseNamesById[file.workspaceId],
            fileType: auraFileTypeForExtension(file.extension),
            onTap: () => context.pushNamed(
              AppRoutes.documentViewer,
              pathParameters: <String, String>{'id': file.id},
            ),
          ),
      ],
      onCreateCourse: () => context.pushNamed(AppRoutes.createWorkspace),
      onOpenSearch: () => context.pushNamed(AppRoutes.search),
      onOpenSettings: () => context.pushNamed(AppRoutes.settings),
      onRefresh: () async {
        await ref.read(homeViewModelProvider.notifier).refresh();
        ref.invalidate(workspaceListViewModelProvider);
      },
    );
  }
}
