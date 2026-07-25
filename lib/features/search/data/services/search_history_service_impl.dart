import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../../domain/services/search_history_service.dart';

class SearchHistoryServiceImpl implements SearchHistoryService {
  final SearchHistoryRepository _repository;

  SearchHistoryServiceImpl(this._repository);

  @override
  Future<void> addQuery(SearchHistoryEntry entry) async {
    final recent = await _repository.getRecentEntries(limit: 100);
    try {
      final existing = recent.firstWhere((e) => e.query.toLowerCase() == entry.query.toLowerCase());
      await _repository.updateEntry(existing.copyWith(
        lastUsed: DateTime.now(),
        hitCount: existing.hitCount + 1,
        resultCount: entry.resultCount,
      ));
    } catch (_) {
      await _repository.saveEntry(entry);
    }
  }

  @override
  Future<List<SearchHistoryEntry>> getRecentQueries({int limit = 50}) async {
    return _repository.getRecentEntries(limit: limit);
  }

  @override
  Future<void> pinQuery(String id) async {
    final entries = await _repository.getRecentEntries(limit: 100);
    try {
      final entry = entries.firstWhere((e) => e.id == id);
      await _repository.updateEntry(entry.copyWith(pinned: true));
    } catch (_) {
      // Ignore if not found
    }
  }

  @override
  Future<void> deleteQuery(String id) async {
    await _repository.deleteEntry(id);
  }

  @override
  Future<void> clearHistory() async {
    await _repository.clearAll();
  }
}
