import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/document_viewer_viewmodel.dart';
import '../widgets/base_viewer_screen.dart';
import '../widgets/viewer_registry.dart';

class DocumentViewerScreen extends ConsumerWidget {
  final String documentId;

  const DocumentViewerScreen({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(documentViewerViewModelProvider(documentId));

    return stateAsync.when(
      data: (state) {
        if (state.file == null) {
          return const BaseViewerScreen(
            title: 'Error',
            error: 'Document file not found.',
            child: SizedBox.shrink(),
          );
        }

        return ViewerRegistry.getViewer(state.viewerType, state.file!);
      },
      loading: () => const BaseViewerScreen(
        title: 'Loading Document...',
        isLoading: true,
        child: SizedBox.shrink(),
      ),
      error: (err, stack) => BaseViewerScreen(
        title: 'Error',
        error: err.toString(),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
