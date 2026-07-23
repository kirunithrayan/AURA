import 'ai_provider.dart';
import 'ai_provider_local.dart';

/// Registry to resolve the active AIProvider.
/// Allows swapping between LocalRetrievalProvider and future LocalLLMProvider.
class AIProviderRegistry {
  AIProviderRegistry._();

  static AIProvider? _activeProvider;

  /// Gets the currently configured AI Provider.
  static AIProvider get provider {
    _activeProvider ??= LocalRetrievalProvider();
    return _activeProvider!;
  }

  /// Sets the active AI Provider (e.g., when switching via settings).
  static void setProvider(AIProvider provider) {
    _activeProvider = provider;
  }
}
