import '../providers/ai_provider.dart';
import '../entities/ai_config.dart';

abstract class AiProviderFactory {
  /// Creates an AiProvider based on the given configuration.
  AiProvider createProvider(AiConfig config);
}
