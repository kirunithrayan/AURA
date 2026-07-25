import 'viewer_command.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';

class ZoomCommand implements ViewerCommand {
  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    if (payload == 'in') {
      notifier.zoomIn();
    } else if (payload == 'out') {
      notifier.zoomOut();
    } else if (payload == 'reset') {
      notifier.resetZoom();
    }
  }
}
