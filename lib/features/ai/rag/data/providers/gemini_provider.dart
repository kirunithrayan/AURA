import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/ai_stream_event.dart';

class GeminiProvider implements AiProvider {

  GeminiProvider(this.config) {
    if (config.apiKey.isEmpty) {
      throw ArgumentError('API Key must be provided for GeminiProvider');
    }
    _model = GenerativeModel(
      model: config.modelName.isEmpty ? 'gemini-1.5-pro' : config.modelName,
      apiKey: config.apiKey,
      generationConfig: GenerationConfig(
        temperature: config.temperature,
      ),
    );
  }
  @override
  final AiConfig config;
  
  late final GenerativeModel _model;

  @override
  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('GeminiProvider generateContent error: $e');
    }
  }

  @override
  Stream<AiStreamEvent> streamGenerateContent(String prompt) async* {
    try {
      final stream = _model.generateContentStream([Content.text(prompt)]);
      
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        final text = chunk.text ?? '';
        if (text.isNotEmpty) {
          buffer.write(text);
          yield AiStreamToken(text);
        }
      }
      yield AiStreamComplete(buffer.toString());
    } catch (e) {
      yield AiStreamError('GeminiProvider stream error: $e');
    }
  }
}
