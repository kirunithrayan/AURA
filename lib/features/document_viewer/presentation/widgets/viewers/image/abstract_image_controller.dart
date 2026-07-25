abstract class AbstractImageController {
  Future<void> openImage(String path);
  void zoomIn();
  void zoomOut();
  void resetZoom();
  void rotateLeft();
  void rotateRight();
  double getZoomLevel();
  void close();
}
