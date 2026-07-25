import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../base_viewer_screen.dart';

class UnsupportedViewerPlaceholder extends StatelessWidget {
  final WorkspaceFile file;

  const UnsupportedViewerPlaceholder({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return BaseViewerScreen(
      title: file.fileName,
      file: file,
      child: AuraEmptyState(
        icon: Icons.warning_amber_rounded,
        title: 'Unsupported File',
        message: 'AURA does not currently support viewing files of type .${file.extension}.',
      ),
    );
  }
}
