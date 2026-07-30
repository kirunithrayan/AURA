import '../entities/ai_stream_event.dart';
import '../entities/ai_config.dart';

abstract class AiProvider {
  /// The configuration used by this provider.
  AiConfig get config;

  /// Generate a complete response synchronously.
  Future<String> generateContent(String prompt);

  /// Stream a response piece-by-piece as it is generated.
  Stream<AiStreamEvent> streamGenerateContent(String prompt);
}
