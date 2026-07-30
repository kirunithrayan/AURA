class ViewerSearchResult {

  const ViewerSearchResult({
    required this.matchCount,
    required this.currentIndex,
    required this.matches,
  });
  final int matchCount;
  final int currentIndex;
  final List<String> matches;
}
