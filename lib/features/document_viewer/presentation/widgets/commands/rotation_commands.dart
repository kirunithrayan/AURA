import 'viewer_command.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';

class RotateCommand implements ViewerCommand {
  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    if (payload == 'left') {
      notifier.rotateLeft();
    } else if (payload == 'right') {
      notifier.rotateRight();
    }
  }
}
