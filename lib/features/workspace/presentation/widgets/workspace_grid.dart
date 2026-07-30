import 'package:flutter/material.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../domain/entities/workspace.dart';
import 'workspace_card.dart';

class WorkspaceGrid extends StatelessWidget {

  const WorkspaceGrid({
    super.key,
    required this.workspaces,
    required this.onTap,
  });
  final List<Workspace> workspaces;
  final Function(Workspace) onTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: UiConstants.workspaceGridCrossAxisCount,
        childAspectRatio: UiConstants.workspaceGridChildAspectRatio,
        crossAxisSpacing: UiConstants.gridSpacing,
        mainAxisSpacing: UiConstants.gridSpacing,
      ),
      itemCount: workspaces.length,
      itemBuilder: (context, index) => AnimatedListItem(
          index: index,
          child: WorkspaceCard(
            workspace: workspaces[index],
            onTap: () => onTap(workspaces[index]),
          ),
        ),
    );
}
