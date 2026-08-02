import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/ai_provider_factory.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/errors/ai_errors.dart';
import 'gemini_provider.dart';
import 'stub_local_provider.dart';

class AiProviderFactoryImpl implements AiProviderFactory {
  @override
  AiProvider createProvider(AiConfig config) {
    switch (config.providerName.toLowerCase()) {
      case 'gemini':
        if (config.apiKey.trim().isEmpty) {
          throw const MissingApiKeyException('gemini');
        }
        return GeminiProvider(config);

      // Explicit opt-in only. Never used as a fallback: a misconfigured
      // provider must fail visibly rather than return placeholder text.
      case 'stub':
        return StubLocalProvider(config);

      default:
        throw UnsupportedProviderException(config.providerName);
    }
  }
}
