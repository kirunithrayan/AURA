abstract class AbstractPdfController {
  Future<void> openDocument(String path);
  void jumpToPage(int page);
  void nextPage();
  void previousPage();
  void zoomIn();
  void zoomOut();
  void resetZoom();
  int getCurrentPage();
  int getPageCount();
  double getZoomLevel();
  void close();
}
