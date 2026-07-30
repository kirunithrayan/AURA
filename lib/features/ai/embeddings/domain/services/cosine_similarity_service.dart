import 'dart:math';

/// Service for calculating mathematical similarities between embeddings.
class CosineSimilarityService {
  const CosineSimilarityService();

  /// Calculates the cosine similarity between two vectors.
  /// Returns a value between -1.0 and 1.0.
  double calculateSimilarity(List<double> v1, List<double> v2) {
    if (v1.length != v2.length || v1.isEmpty) {
      throw ArgumentError('Vectors must be non-empty and of the same length');
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      norm1 += v1[i] * v1[i];
      norm2 += v2[i] * v2[i];
    }

    if (norm1 == 0 || norm2 == 0) return 0.0;
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }
}
