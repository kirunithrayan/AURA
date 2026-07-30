enum ViewerCapability {
  zoom,
  rotate,
  pageNavigation,
  textSelection,
  textSettings,
  metadata,
  share,
  openExternally,
  copy,
  search,
  keyboardShortcuts,
}

class ViewerActionState {

  const ViewerActionState({
    required this.capability,
    required this.enabled,
    this.disabledReason,
  });
  final ViewerCapability capability;
  final bool enabled;
  final String? disabledReason;
}
