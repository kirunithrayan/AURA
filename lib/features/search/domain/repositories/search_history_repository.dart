import '../entities/search_history_entry.dart';

abstract class SearchHistoryRepository {
  Future<void> saveEntry(SearchHistoryEntry entry);
  Future<List<SearchHistoryEntry>> getRecentEntries({int limit = 50});
  Future<void> deleteEntry(String id);
  Future<void> updateEntry(SearchHistoryEntry entry);
  Future<void> clearAll();
}
