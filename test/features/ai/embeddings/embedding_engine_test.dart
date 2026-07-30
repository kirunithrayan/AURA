import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/ai/embeddings/domain/services/text_preprocessor.dart';
import 'package:aura/features/ai/embeddings/domain/services/document_chunking_service.dart';
import 'package:aura/features/ai/embeddings/domain/services/cosine_similarity_service.dart';

void main() {
  group('TextPreprocessor', () {
    const preprocessor = TextPreprocessor();

    test('normalizes multiple spaces', () {
      const input = 'This   is    a   test.';
      const expected = 'This is a test.';
      expect(preprocessor.preprocess(input), expected);
    });

    test('preserves paragraph boundaries', () {
      const input = 'Para 1.\n\n\n\nPara 2.';
      const expected = 'Para 1.\n\nPara 2.';
      expect(preprocessor.preprocess(input), expected);
    });

    test('removes invalid control characters', () {
      const input = 'Invalid\x00Control\x01Chars';
      const expected = 'InvalidControlChars';
      expect(preprocessor.preprocess(input), expected);
    });

    test('normalizes smart quotes', () {
      const input = '“Smart” and ‘Quotes’';
      const expected = '"Smart" and \'Quotes\'';
      expect(preprocessor.preprocess(input), expected);
    });
  });

  group('DocumentChunkingService', () {
    const chunkingService = DocumentChunkingService();
    
    test('chunks long text correctly based on size', () {
      final text = List.generate(500, (index) => 'word').join(' ');
      const config = ChunkingConfig(chunkSize: 1000, chunkOverlap: 100);
      
      final chunks = chunkingService.chunkText('doc_1', text, config: config);
      
      expect(chunks, isNotEmpty);
      expect(chunks.first.content.length, lessThanOrEqualTo(1000));
      expect(chunks.first.documentId, 'doc_1');
    });

    test('empty text returns empty chunk list', () {
      final chunks = chunkingService.chunkText('doc_1', '');
      expect(chunks, isEmpty);
    });
  });

  group('CosineSimilarityService', () {
    const service = CosineSimilarityService();

    test('calculates correct similarity for identical vectors', () {
      final v1 = [1.0, 2.0, 3.0];
      final v2 = [1.0, 2.0, 3.0];
      
      final similarity = service.calculateSimilarity(v1, v2);
      expect(similarity, closeTo(1.0, 0.0001));
    });

    test('calculates correct similarity for orthogonal vectors', () {
      final v1 = [1.0, 0.0];
      final v2 = [0.0, 1.0];
      
      final similarity = service.calculateSimilarity(v1, v2);
      expect(similarity, closeTo(0.0, 0.0001));
    });
    
    test('calculates correct similarity for opposite vectors', () {
      final v1 = [1.0, 1.0];
      final v2 = [-1.0, -1.0];
      
      final similarity = service.calculateSimilarity(v1, v2);
      expect(similarity, closeTo(-1.0, 0.0001));
    });

    test('throws error for mismatched lengths', () {
      final v1 = [1.0, 2.0];
      final v2 = [1.0];
      
      expect(() => service.calculateSimilarity(v1, v2), throwsArgumentError);
    });
  });
}
