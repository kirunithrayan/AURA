import '../../viewmodels/document_viewer_viewmodel.dart';

abstract class ViewerCommand {
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]);
}
