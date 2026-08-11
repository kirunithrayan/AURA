import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../../../domain/entities/reading_preferences.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import '../base_viewer_screen.dart';
import 'viewer_lifecycle.dart';
import '../../../../ai/rag/presentation/widgets/explain_sheet.dart';

class TextViewerWidget extends ConsumerStatefulWidget {

  const TextViewerWidget({super.key, required this.file});
  final WorkspaceFile file;

  @override
  ConsumerState<TextViewerWidget> createState() => _TextViewerWidgetState();
}

class _TextViewerWidgetState extends ConsumerState<TextViewerWidget> implements ViewerLifecycle {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    onViewerOpened();
  }

  @override
  void dispose() {
    onViewerClosed();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void onViewerOpened() {}

  @override
  void onViewerPaused() {}

  @override
  void onViewerResumed() {}

  @override
  void onViewerClosed() {
    ref.read(documentViewerViewModelProvider(widget.file.id).notifier).updateScrollPosition(_scrollController.hasClients ? _scrollController.offset : 0.0);
    ref.read(documentViewerViewModelProvider(widget.file.id).notifier).saveViewerState();
  }

  Color _getBackgroundColor(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.light: return Colors.white;
      case ReadingTheme.dark: return const Color(0xFF121212);
      case ReadingTheme.sepia: return const Color(0xFFF4ECD8);
      case ReadingTheme.system: return AppColors.background;
    }
  }

  Color _getTextColor(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.light: return Colors.black87;
      case ReadingTheme.dark: return Colors.white70;
      case ReadingTheme.sepia: return const Color(0xFF5B4636);
      case ReadingTheme.system: return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(documentViewerViewModelProvider(widget.file.id));

    return stateAsync.when(
      data: (state) {
        if (state.textDocument == null) {
          return const BaseViewerScreen(title: 'Loading', isLoading: true, child: Center(child: CircularProgressIndicator()));
        }

        final doc = state.textDocument!;
        final prefs = state.readingPreferences;

        if (_scrollController.hasClients && _scrollController.offset == 0 && state.viewState.scrollPosition > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(state.viewState.scrollPosition);
            }
          });
        }

        return BaseViewerScreen(
          title: widget.file.fileName,
          file: widget.file,
          child: Container(
            color: _getBackgroundColor(prefs.readingTheme),
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollEndNotification) {
                  ref.read(documentViewerViewModelProvider(widget.file.id).notifier)
                     .updateScrollPosition(scrollInfo.metrics.pixels);
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24.0),
                child: SelectableText(
                  doc.content,
                  style: TextStyle(
                    fontSize: prefs.fontSize,
                    height: prefs.lineSpacing,
                    color: _getTextColor(prefs.readingTheme),
                  ),
                  contextMenuBuilder: _buildSelectionMenu,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const BaseViewerScreen(title: 'Loading', isLoading: true, child: SizedBox.shrink()),
      error: (e, st) => BaseViewerScreen(title: 'Error', error: e.toString(), child: const SizedBox.shrink()),
    );
  }

  /// Appends "Explain with AURA" to the platform selection toolbar, leaving
  /// every existing action (copy, select all, share, ...) in place.
  Widget _buildSelectionMenu(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final List<ContextMenuButtonItem> items =
        List<ContextMenuButtonItem>.from(editableTextState.contextMenuButtonItems);

    final TextEditingValue value = editableTextState.textEditingValue;
    final TextSelection selection = value.selection;

    if (selection.isValid && !selection.isCollapsed) {
      items.add(
        ContextMenuButtonItem(
          label: 'Explain with AURA',
          onPressed: () {
            final String selected = selection.textInside(value.text);
            editableTextState.hideToolbar();
            if (selected.trim().isEmpty) {
              return;
            }
            showExplainSheet(context: context, selection: selected);
          },
        ),
      );
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: items,
    );
  }
}


