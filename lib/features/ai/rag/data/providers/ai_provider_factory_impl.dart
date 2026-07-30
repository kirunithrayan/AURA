import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/ai_provider_factory.dart';
import '../../domain/entities/ai_config.dart';
import 'gemini_provider.dart';
import 'stub_local_provider.dart';

class AiProviderFactoryImpl implements AiProviderFactory {
  @override
  AiProvider createProvider(AiConfig config) {
    switch (config.providerName.toLowerCase()) {
      case 'gemini':
        if (config.apiKey.trim().isEmpty) {
          return StubLocalProvider(config);
        }
        return GeminiProvider(config);
      case 'local_onnx':
      case 'stub':
      default:
        return StubLocalProvider(config);
    }
  }
}
