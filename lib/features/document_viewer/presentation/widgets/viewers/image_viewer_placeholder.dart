import 'package:flutter/material.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../base_viewer_screen.dart';

class ImageViewerPlaceholder extends StatelessWidget {

  const ImageViewerPlaceholder({super.key, required this.file});
  final WorkspaceFile file;

  @override
  Widget build(BuildContext context) => BaseViewerScreen(
      title: file.fileName,
      file: file,
      child: const AuraEmptyState(
        icon: Icons.image,
        title: 'Image Viewer',
        message: 'Image rendering logic will be implemented in a future phase.',
      ),
    );
}
