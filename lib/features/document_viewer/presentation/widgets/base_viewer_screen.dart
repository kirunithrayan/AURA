import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/widgets/aura_loading.dart';
import 'package:aura/core/widgets/aura_empty_state.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'viewer_toolbar.dart';
import 'viewer_bottom_toolbar.dart';
import 'shortcut_manager.dart';
import 'viewer_providers.dart';
import '../../domain/entities/viewer_type.dart';
import '../../domain/utils/viewer_capabilities_helper.dart';
import '../../core/utils/file_type_helper.dart';

class BaseViewerScreen extends ConsumerStatefulWidget {

  const BaseViewerScreen({
    super.key,
    required this.title,
    required this.child,
    this.isLoading = false,
    this.error,
    this.file,
    this.actions,
  });
  final String title;
  final Widget child;
  final bool isLoading;
  final String? error;
  final WorkspaceFile? file;
  final List<Widget>? actions;

  @override
  ConsumerState<BaseViewerScreen> createState() => _BaseViewerScreenState();
}

class _BaseViewerScreenState extends ConsumerState<BaseViewerScreen>
    with SingleTickerProviderStateMixin {
  /// Drives both toolbars together: 1 = fully shown, 0 = fully hidden.
  ///
  /// Created eagerly: formats without auto-hide never touch it during build, so
  /// a lazy initialiser would first run inside dispose().
  late final AnimationController _chrome;

  /// Downward scroll accumulated since the chrome was last shown.
  double _scrolledDown = 0;

  @override
  void initState() {
    super.initState();
    _chrome = AnimationController(
      vsync: this,
      duration: AuraMotion.standard,
      value: 1,
    );
  }

  @override
  void dispose() {
    _chrome.dispose();
    super.dispose();
  }

  /// Auto-hide applies only to formats with a continuous scroll axis.
  bool _autoHideApplies(ViewerType? type) =>
      type == ViewerType.text || type == ViewerType.docx;

  void _show() {
    _scrolledDown = 0;
    if (_chrome.status != AnimationStatus.forward && _chrome.value != 1) {
      _animate(forward: true);
    }
  }

  void _hide() {
    _scrolledDown = 0;
    if (_chrome.status != AnimationStatus.reverse && _chrome.value != 0) {
      _animate(forward: false);
    }
  }

  void _animate({required bool forward}) {
    // Honour the platform reduced-motion setting.
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      _chrome.duration = AuraMotion.reduced;
      _chrome.value = forward ? 1 : 0;
      _chrome.duration = AuraMotion.standard;
      return;
    }
    if (forward) {
      _chrome.forward();
    } else {
      _chrome.reverse();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final double? delta = notification.scrollDelta;
      if (delta != null) {
        if (delta > 0) {
          _scrolledDown += delta;
          if (_scrolledDown > AuraLayout.appBarHeight) {
            _hide();
          }
        } else if (delta < 0) {
          _show();
        }
      }
    }
    // Never consume: the text viewer's own listener still feeds
    // reading-position persistence, and every other handler is unaffected.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final viewerType = widget.file != null
        ? FileTypeHelper.getViewerType(widget.file!.extension)
        : null;
    final capabilities = viewerType?.capabilities ?? {};
    final actionRegistry = ref.watch(viewerActionRegistryProvider);

    Widget body = _buildBody();

    if (widget.file != null) {
      body = ViewerShortcutManager(
        file: widget.file!,
        capabilities: capabilities,
        actionRegistry: actionRegistry,
        child: body,
      );
    }

    final bool autoHide = _autoHideApplies(viewerType);
    if (autoHide) {
      body = NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: body,
      );
    }

    final ViewerToolbar toolbar = ViewerToolbar(
      file: widget.file,
      capabilities: capabilities,
      actionRegistry: actionRegistry,
    );
    final Widget? bottomToolbar = widget.file == null
        ? null
        : ViewerBottomToolbar(
            file: widget.file!,
            capabilities: capabilities,
            actionRegistry: actionRegistry,
          );

    if (!autoHide) {
      return Scaffold(
        appBar: toolbar,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: body),
              if (bottomToolbar != null) bottomToolbar,
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _chrome,
      builder: (BuildContext context, Widget? _) {
        final double t = AuraMotion.standardCurve.transform(_chrome.value);
        // Fully hidden chrome leaves the tree entirely, so no invisible focus
        // or semantics targets remain behind.
        final bool mounted = t > 0;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(AuraLayout.appBarHeight * t),
            child: mounted
                ? ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: t,
                      child: toolbar,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: body),
                if (bottomToolbar != null && mounted)
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: t,
                      child: bottomToolbar,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (widget.isLoading) {
      return const AuraLoading();
    }

    if (widget.error != null) {
      return AuraEmptyState(
        icon: Icons.error_outline,
        title: 'Error Loading Document',
        message: widget.error!,
      );
    }

    return widget.child;
  }
}
