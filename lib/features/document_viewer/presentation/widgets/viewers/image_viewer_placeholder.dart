import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../base_viewer_screen.dart';

class ImageViewerPlaceholder extends StatelessWidget {
  final WorkspaceFile file;

  const ImageViewerPlaceholder({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return BaseViewerScreen(
      title: file.fileName,
      file: file,
      child: const AuraEmptyState(
        icon: Icons.image,
        title: 'Image Viewer',
        message: 'Image rendering logic will be implemented in a future phase.',
      ),
    );
  }
}
