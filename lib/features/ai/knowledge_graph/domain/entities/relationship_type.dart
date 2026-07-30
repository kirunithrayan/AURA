/// Represents the nature of the relationship between two KnowledgeNodes.
enum RelationshipType {
  /// General semantic similarity (document-to-document or concept-to-concept).
  semanticSimilarity,
  
  /// A document explicitly mentions or defines a concept.
  mentions,
  
  /// A concept is a subtopic of another concept, or highly related.
  relatedTo,
  
  /// Two documents are identified as potential duplicates.
  duplicate,
}
