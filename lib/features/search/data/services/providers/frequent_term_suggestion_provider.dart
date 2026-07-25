import '../../domain/entities/search_suggestion.dart';
import '../../domain/services/search_suggestion_provider.dart';
import '../../../../database/database_helper.dart';

class FrequentTermSuggestionProvider implements SuggestionProvider {
  final DatabaseHelper _dbHelper;

  FrequentTermSuggestionProvider(this._dbHelper);

  @override
  String get providerId => 'frequent_term';

  @override
  Future<List<SearchSuggestion>> getSuggestions(String partialQuery) async {
    // In a production app, frequent terms would be indexed or aggregated.
    // For now, we will return some hardcoded global suggestions or 
    // run a simple aggregate over search history if partial query is provided.
    
    if (partialQuery.trim().isEmpty) return [];

    // Let's query search history grouping by query string ordered by count
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT query, SUM(hit_count) as total_hits 
      FROM search_history 
      WHERE query LIKE ? 
      GROUP BY query 
      ORDER BY total_hits DESC 
      LIMIT 3
      ''',
      ['%${partialQuery.toLowerCase()}%']
    );

    return maps
        .map((e) => SearchSuggestion(text: e['query'] as String, type: SuggestionType.frequent))
        .toList();
  }
}
