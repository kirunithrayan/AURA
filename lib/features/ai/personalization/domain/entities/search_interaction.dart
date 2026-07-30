class SearchInteraction {

  const SearchInteraction({
    required this.id,
    required this.query,
    this.clickedDocumentId,
    required this.timestamp,
  });
  final String id;
  final String query;
  final String? clickedDocumentId;
  final int timestamp;
}
