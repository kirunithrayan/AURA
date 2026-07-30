import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/search/domain/entities/search_query.dart';
import 'package:aura/features/search/domain/entities/search_result.dart';
import 'package:aura/features/search/domain/entities/search_explanation.dart';
import 'package:aura/features/search/domain/entities/hybrid_ranking_weights.dart';
import 'package:aura/features/search/data/engines/hybrid_ranking_engine.dart';
import 'package:aura/features/document_metadata/domain/entities/document_metadata.dart';

void main() {
  group('HybridRankingEngine', () {
    late HybridRankingEngine engine;
    
    setUp(() {
      engine = HybridRankingEngine(const HybridRankingWeights());
    });

    test('should rank based on semantic and keyword scores correctly', () async {
      final doc1 = DocumentMetadata(
        id: '1',
        fileName: 'doc1.pdf',
        fileExtension: 'pdf',
        filePath: '/some/path/doc1.pdf',
        importedAt: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        modifiedAt: DateTime.now().millisecondsSinceEpoch,
        workspaceId: 'ws1',
        isFavorite: false,
        isPinned: false,
      );

      final result1 = SearchResult(
        metadata: doc1,
        score: 0.0,
        searchEngineType: 'semantic',
        explanation: const SearchExplanation(
          semanticScore: 0.8,
          keywordScore: 0.0,
          explanation: '',
        ),
      );

      final result2 = SearchResult(
        metadata: doc1,
        score: 0.0,
        searchEngineType: 'keyword',
        explanation: const SearchExplanation(
          semanticScore: 0.0,
          keywordScore: 0.9,
          explanation: '',
        ),
      );

      const query = SearchQuery(keyword: 'test');
      
      final ranked = await engine.rank(query, [result1, result2]);
      
      // Expected semantic: 0.8 * 0.6 = 0.48
      // Expected keyword: 0.9 * 0.4 = 0.36
      expect(ranked[0].explanation?.semanticScore, 0.8);
      expect(ranked[1].explanation?.keywordScore, 0.9);
    });
  });
}
