import '../entities/search_history_entry.dart';

abstract class SearchHistoryService {
  Future<void> addQuery(SearchHistoryEntry entry);
  Future<List<SearchHistoryEntry>> getRecentQueries({int limit = 50});
  Future<void> pinQuery(String id);
  Future<void> deleteQuery(String id);
  Future<void> clearHistory();
}
