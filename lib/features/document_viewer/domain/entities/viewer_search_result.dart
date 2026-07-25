class ViewerSearchResult {
  final int matchCount;
  final int currentIndex;
  final List<String> matches;

  const ViewerSearchResult({
    required this.matchCount,
    required this.currentIndex,
    required this.matches,
  });
}
