import 'package:equatable/equatable.dart';

class AiConfig extends Equatable {

  const AiConfig({
    required this.apiKey,
    this.providerName = 'gemini',
    this.modelName = 'gemini-1.5-pro',
    this.temperature = 0.2,
    this.similarityThreshold = 0.6,
  });
  final String apiKey;
  final String providerName; // e.g., 'gemini', 'local_onnx'
  final String modelName;
  final double temperature;
  final double similarityThreshold;

  @override
  List<Object?> get props => [
        apiKey,
        providerName,
        modelName,
        temperature,
        similarityThreshold,
      ];
}
