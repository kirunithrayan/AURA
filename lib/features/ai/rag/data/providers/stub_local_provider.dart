import 'dart:async';
import '../../domain/providers/ai_provider.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/ai_stream_event.dart';

class StubLocalProvider implements AiProvider {

  StubLocalProvider(this.config);
  @override
  final AiConfig config;

  @override
  Future<String> generateContent(String prompt) async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));
    return 'This is a stub response from StubLocalProvider (Model: ${config.modelName}).';
  }

  @override
  Stream<AiStreamEvent> streamGenerateContent(String prompt) async* {
    final text = 'This is a streaming stub response from StubLocalProvider (Model: ${config.modelName}).';
    final words = text.split(' ');
    
    final buffer = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      final chunk = words[i] + (i < words.length - 1 ? ' ' : '');
      buffer.write(chunk);
      yield AiStreamToken(chunk);
    }
    
    yield AiStreamComplete(buffer.toString());
  }
}
