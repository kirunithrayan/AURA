import 'dart:math';

/// Utility class for vector mathematics, primarily used for embedding comparisons.
class VectorMath {
  VectorMath._();

  /// Calculates the cosine similarity between two vectors.
  /// Both vectors must have the same length.
  /// Returns a value between -1.0 (opposite) and 1.0 (identical).
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same length (a: ${a.length}, b: ${b.length})');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// Calculates the Euclidean distance between two vectors.
  static double euclideanDistance(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same length');
    }

    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }

    return sqrt(sum);
  }
}
