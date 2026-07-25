import '../entities/viewer_type.dart';
import '../entities/viewer_capability.dart';

extension ViewerTypeCapabilities on ViewerType {
  Set<ViewerCapability> get capabilities {
    switch (this) {
      case ViewerType.pdf:
        return {
          ViewerCapability.zoom,
          ViewerCapability.pageNavigation,
          ViewerCapability.share,
          ViewerCapability.metadata,
          ViewerCapability.openExternally,
          ViewerCapability.keyboardShortcuts,
        };
      case ViewerType.image:
        return {
          ViewerCapability.zoom,
          ViewerCapability.rotate,
          ViewerCapability.share,
          ViewerCapability.metadata,
          ViewerCapability.openExternally,
          ViewerCapability.keyboardShortcuts,
        };
      case ViewerType.text:
      case ViewerType.docx:
        return {
          ViewerCapability.copy,
          ViewerCapability.textSettings,
          ViewerCapability.share,
          ViewerCapability.metadata,
          ViewerCapability.openExternally,
          ViewerCapability.keyboardShortcuts,
        };
      case ViewerType.unsupported:
      default:
        return {
          ViewerCapability.share,
          ViewerCapability.openExternally,
        };
    }
  }
}
