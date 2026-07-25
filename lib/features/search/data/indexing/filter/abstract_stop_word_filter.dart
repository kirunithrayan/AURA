/// Contract for filtering stop words from a stream of normalized tokens.
abstract class AbstractStopWordFilter {
  /// Returns true if the token should be kept (i.e., is NOT a stop word).
  bool shouldKeep(String normalizedToken);
}
