import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../base_viewer_screen.dart';

class DocxViewerPlaceholder extends StatelessWidget {
  final WorkspaceFile file;

  const DocxViewerPlaceholder({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return BaseViewerScreen(
      title: file.fileName,
      file: file,
      child: const AuraEmptyState(
        icon: Icons.description,
        title: 'DOCX Viewer',
        message: 'DOCX rendering logic will be implemented in a future phase.',
      ),
    );
  }
}
