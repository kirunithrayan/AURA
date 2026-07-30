import 'package:equatable/equatable.dart';
import 'citation.dart';

class AiResponse extends Equatable {

  const AiResponse({
    required this.text,
    this.citations = const [],
    this.confidence,
    required this.provider,
    required this.model,
    this.responseTime,
    this.tokenUsage,
  });
  final String text;
  final List<Citation> citations;
  final double? confidence;
  final String provider;
  final String model;
  final Duration? responseTime;
  final int? tokenUsage;

  @override
  List<Object?> get props => [
        text,
        citations,
        confidence,
        provider,
        model,
        responseTime,
        tokenUsage,
      ];
}
