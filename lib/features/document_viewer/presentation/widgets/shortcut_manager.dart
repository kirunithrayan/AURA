import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

class ViewerShortcutManager extends ConsumerWidget {

  const ViewerShortcutManager({
    super.key,
    required this.child,
    required this.file,
    required this.capabilities,
    required this.actionRegistry,
  });
  final Widget child;
  final WorkspaceFile file;
  final Set<ViewerCapability> capabilities;
  final ViewerActionRegistry actionRegistry;

  void _execute(WidgetRef ref, BuildContext context, ViewerCapability cap, [dynamic payload]) {
    actionRegistry.getCommand(cap)?.execute(
      ref.read(documentViewerViewModelProvider(file.id).notifier),
      payload ?? context,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!capabilities.contains(ViewerCapability.keyboardShortcuts)) {
      return child;
    }

    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.equal): const ZoomInIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.minus): const ZoomOutIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PrevPageIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextPageIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
      },
      actions: {
        ZoomInIntent: CallbackAction<ZoomInIntent>(onInvoke: (_) {
           _execute(ref, context, ViewerCapability.zoom, 'in');
           return null;
        }),
        ZoomOutIntent: CallbackAction<ZoomOutIntent>(onInvoke: (_) {
           _execute(ref, context, ViewerCapability.zoom, 'out');
           return null;
        }),
        PrevPageIntent: CallbackAction<PrevPageIntent>(onInvoke: (_) {
           if (capabilities.contains(ViewerCapability.pageNavigation)) {
             _execute(ref, context, ViewerCapability.pageNavigation, 'prev');
           } else if (capabilities.contains(ViewerCapability.rotate)) {
             _execute(ref, context, ViewerCapability.rotate, 'left');
           }
           return null;
        }),
        NextPageIntent: CallbackAction<NextPageIntent>(onInvoke: (_) {
           if (capabilities.contains(ViewerCapability.pageNavigation)) {
             _execute(ref, context, ViewerCapability.pageNavigation, 'next');
           } else if (capabilities.contains(ViewerCapability.rotate)) {
             _execute(ref, context, ViewerCapability.rotate, 'right');
           }
           return null;
        }),
        SearchIntent: CallbackAction<SearchIntent>(onInvoke: (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search coming in future update.')));
          return null;
        }),
      },
      child: child,
    );
  }
}

class ZoomInIntent extends Intent { const ZoomInIntent(); }
class ZoomOutIntent extends Intent { const ZoomOutIntent(); }
class PrevPageIntent extends Intent { const PrevPageIntent(); }
class NextPageIntent extends Intent { const NextPageIntent(); }
class SearchIntent extends Intent { const SearchIntent(); }
