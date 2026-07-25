class DocumentViewState {
  final int currentPage;
  final int pageCount;
  final double zoomLevel;
  final double rotation;
  final double scrollPosition;
  final int? lastOpenedAt;
  final bool isPasswordProtected;

  const DocumentViewState({
    this.currentPage = 1,
    this.pageCount = 0,
    this.zoomLevel = 1.0,
    this.rotation = 0.0,
    this.scrollPosition = 0.0,
    this.lastOpenedAt,
    this.isPasswordProtected = false,
  });

  DocumentViewState copyWith({
    int? currentPage,
    int? pageCount,
    double? zoomLevel,
    double? rotation,
    double? scrollPosition,
    int? lastOpenedAt,
    bool? isPasswordProtected,
  }) {
    return DocumentViewState(
      currentPage: currentPage ?? this.currentPage,
      pageCount: pageCount ?? this.pageCount,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      rotation: rotation ?? this.rotation,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
    );
  }
}
