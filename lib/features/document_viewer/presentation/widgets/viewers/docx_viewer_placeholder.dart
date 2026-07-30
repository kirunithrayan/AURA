import 'package:flutter/material.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../base_viewer_screen.dart';

class DocxViewerPlaceholder extends StatelessWidget {

  const DocxViewerPlaceholder({super.key, required this.file});
  final WorkspaceFile file;

  @override
  Widget build(BuildContext context) => BaseViewerScreen(
      title: file.fileName,
      file: file,
      child: const AuraEmptyState(
        icon: Icons.description,
        title: 'DOCX Viewer',
        message: 'DOCX rendering logic will be implemented in a future phase.',
      ),
    );
}
