/// Interface to manage lifecycle events for document viewers.
abstract class ViewerLifecycle {
  void onViewerOpened();
  void onViewerPaused();
  void onViewerResumed();
  void onViewerClosed();
}
