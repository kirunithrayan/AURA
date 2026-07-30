/// Static constants for the AI subsystem.
class AIConstants {
  AIConstants._();

  static const String defaultEmbeddingModel = 'default_embedding_model';
  static const String defaultInferenceModel = 'default_inference_model';
  
  static const int minChunkSize = 128;
  static const int maxChunkSize = 8192;
  
  static const double minTemperature = 0.0;
  static const double maxTemperature = 2.0;
}
