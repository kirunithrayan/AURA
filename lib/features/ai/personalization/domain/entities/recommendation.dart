import '../entities/recommendation_type.dart';
import '../../../../search/domain/entities/search_result.dart';

class Recommendation {

  const Recommendation({
    required this.id,
    required this.type,
    required this.document,
    required this.score,
    required this.explanation,
  });
  final String id;
  final RecommendationType type;
  final SearchResult document;
  final double score;
  final String explanation;
}
