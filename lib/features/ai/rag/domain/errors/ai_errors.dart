/// Errors surfaced by the AI provider layer.
///
/// These exist so that a missing or invalid configuration fails loudly at the
/// point of use, rather than silently degrading to a placeholder response.
library;

/// Thrown when an AI provider requires an API key that has not been configured.
class MissingApiKeyException implements Exception {
  const MissingApiKeyException(this.providerName);

  final String providerName;

  @override
  String toString() =>
      'No API key configured for "$providerName". '
      'Add one in Settings → AI Engine Configuration.';
}

/// Thrown when a configuration names a provider that is not implemented.
class UnsupportedProviderException implements Exception {
  const UnsupportedProviderException(this.providerName);

  final String providerName;

  @override
  String toString() => 'Unsupported AI provider: "$providerName".';
}
