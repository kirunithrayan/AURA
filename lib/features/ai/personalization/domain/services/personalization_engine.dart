import 'dart:math';
import 'package:uuid/uuid.dart';

import '../entities/document_interaction.dart';
import '../entities/search_interaction.dart';
import '../entities/personalization_score.dart';
import '../repositories/interaction_repository.dart';

class PersonalizationEngine {

  PersonalizationEngine(this._interactionRepository);
  final InteractionRepository _interactionRepository;
  final Uuid _uuid = const Uuid();

  Future<void> recordDocumentView(String documentId, {int durationMs = 0}) async {
    var interaction = await _interactionRepository.getDocumentInteraction(documentId);
    
    if (interaction == null) {
      interaction = DocumentInteraction(
        id: _uuid.v4(),
        documentId: documentId,
        viewCount: 1,
        readingTimeMs: durationMs,
        lastViewedAt: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      interaction = DocumentInteraction(
        id: interaction.id,
        documentId: interaction.documentId,
        viewCount: interaction.viewCount + 1,
        readingTimeMs: interaction.readingTimeMs + durationMs,
        lastViewedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    await _interactionRepository.saveDocumentInteraction(interaction);
  }

  Future<void> recordSearchQuery(String query, {String? clickedDocumentId}) async {
    final interaction = SearchInteraction(
      id: _uuid.v4(),
      query: query,
      clickedDocumentId: clickedDocumentId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _interactionRepository.saveSearchInteraction(interaction);
  }

  Future<PersonalizationScore> calculateScore(String documentId, {bool isFavorite = false}) async {
    final interaction = await _interactionRepository.getDocumentInteraction(documentId);
    
    if (interaction == null && !isFavorite) {
      return PersonalizationScore.empty();
    }

    double readingScore = 0.0;
    double recencyBoost = 1.0;
    
    if (interaction != null) {
      // Normalize reading score based on view count and reading time.
      // This is a simplified heuristic.
      readingScore = min(1.0, (interaction.viewCount * 0.1) + (interaction.readingTimeMs / 60000.0 * 0.05));
      
      // Calculate recency boost (decays over time)
      final now = DateTime.now().millisecondsSinceEpoch;
      final daysSinceLastView = (now - interaction.lastViewedAt) / (1000 * 60 * 60 * 24);
      recencyBoost = max(1.0, 2.0 * exp(-0.1 * daysSinceLastView)); // Max boost of 2.0, decaying to 1.0
    }

    final favoriteBoost = isFavorite ? 1.5 : 1.0;
    
    // For now, search score is 0.0 as we need a more complex way to map queries to document relevance
    // outside of the immediate click (which is captured by reading score).
    const searchScore = 0.0;

    final finalScore = (readingScore + searchScore) * favoriteBoost * recencyBoost;

    return PersonalizationScore(
      readingScore: readingScore,
      searchScore: searchScore,
      favoriteBoost: favoriteBoost,
      recencyBoost: recencyBoost,
      finalScore: finalScore,
    );
  }
}
