import 'package:uuid/uuid.dart';

import '../entities/recommendation.dart';
import '../entities/recommendation_type.dart';
import '../repositories/interaction_repository.dart';
import 'personalization_engine.dart';
import '../../../../document_metadata/domain/services/document_metadata_service.dart';
import '../../../../search/domain/entities/search_result.dart';

class RecommendationService {

  RecommendationService(
    this._interactionRepository,
    this._metadataService,
    this._personalizationEngine,
  );
  final InteractionRepository _interactionRepository;
  final DocumentMetadataService _metadataService;
  final PersonalizationEngine _personalizationEngine;
  final Uuid _uuid = const Uuid();

  Future<List<Recommendation>> getRecommendations(String workspaceId) async {
    final recentInteractions = await _interactionRepository.getRecentDocumentInteractions(20);
    final List<Recommendation> recommendations = [];
    
    for (var interaction in recentInteractions) {
      final metaResult = await _metadataService.getMetadata(interaction.documentId);
      
      // Since it's dartz Either, we can use fold
      await metaResult.fold(
        (failure) async {}, // Ignore failures
        (metadata) async {
          if (metadata.workspaceId == workspaceId) {
            final pScore = await _personalizationEngine.calculateScore(
              metadata.id, 
              isFavorite: metadata.isFavorite
            );
            
            final searchResult = SearchResult(
              metadata: metadata,
              score: pScore.finalScore,
              searchEngineType: 'recommendation',
            );
            
            RecommendationType type = RecommendationType.recentlyViewed;
            if (interaction.readingTimeMs > 60000) {
               type = RecommendationType.continueReading;
            }

            recommendations.add(Recommendation(
              id: _uuid.v4(),
              type: type,
              document: searchResult,
              score: pScore.finalScore,
              explanation: 'Based on your recent activity',
            ));
          }
        }
      );
    }
    
    // Sort descending by score
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    
    // Deduplicate
    final seen = <String>{};
    final uniqueRecommendations = <Recommendation>[];
    for (var rec in recommendations) {
      if (!seen.contains(rec.document.metadata.id)) {
        seen.add(rec.document.metadata.id);
        uniqueRecommendations.add(rec);
      }
    }
    
    return uniqueRecommendations;
  }
}
