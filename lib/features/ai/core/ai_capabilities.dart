import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_capabilities.freezed.dart';
part 'ai_capabilities.g.dart';

/// Immutable value object defining the capabilities of an AI module or engine.
/// This prevents boolean explosion and provides a flexible contract for feature toggles.
@freezed
class AICapabilities with _$AICapabilities {
  const factory AICapabilities({
    @Default(false) bool supportsEmbeddings,
    @Default(false) bool supportsStreaming,
    @Default(false) bool supportsVision,
    @Default(false) bool supportsImages,
    @Default(false) bool supportsAudio,
    @Default(false) bool supportsSummaries,
    @Default(false) bool supportsRAG,
    @Default(false) bool supportsFunctionCalling,
    @Default(false) bool supportsKnowledgeGraph,
  }) = _AICapabilities;

  factory AICapabilities.fromJson(Map<String, dynamic> json) => _$AICapabilitiesFromJson(json);
}
