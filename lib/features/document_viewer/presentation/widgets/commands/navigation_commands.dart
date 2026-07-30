import 'viewer_command.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';

class PageNavigationCommand implements ViewerCommand {
  @override
  Future<void> execute(DocumentViewerViewModel notifier, [dynamic payload]) async {
    if (payload == 'next') {
      notifier.nextPage();
    } else if (payload == 'prev') {
      notifier.previousPage();
    } else if (payload is int) {
      notifier.jumpToPage(payload);
    }
  }
}
