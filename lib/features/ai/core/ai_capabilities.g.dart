// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AICapabilitiesImpl _$$AICapabilitiesImplFromJson(Map<String, dynamic> json) =>
    _$AICapabilitiesImpl(
      supportsEmbeddings: json['supportsEmbeddings'] as bool? ?? false,
      supportsStreaming: json['supportsStreaming'] as bool? ?? false,
      supportsVision: json['supportsVision'] as bool? ?? false,
      supportsImages: json['supportsImages'] as bool? ?? false,
      supportsAudio: json['supportsAudio'] as bool? ?? false,
      supportsSummaries: json['supportsSummaries'] as bool? ?? false,
      supportsRAG: json['supportsRAG'] as bool? ?? false,
      supportsFunctionCalling:
          json['supportsFunctionCalling'] as bool? ?? false,
      supportsKnowledgeGraph: json['supportsKnowledgeGraph'] as bool? ?? false,
    );

Map<String, dynamic> _$$AICapabilitiesImplToJson(
        _$AICapabilitiesImpl instance) =>
    <String, dynamic>{
      'supportsEmbeddings': instance.supportsEmbeddings,
      'supportsStreaming': instance.supportsStreaming,
      'supportsVision': instance.supportsVision,
      'supportsImages': instance.supportsImages,
      'supportsAudio': instance.supportsAudio,
      'supportsSummaries': instance.supportsSummaries,
      'supportsRAG': instance.supportsRAG,
      'supportsFunctionCalling': instance.supportsFunctionCalling,
      'supportsKnowledgeGraph': instance.supportsKnowledgeGraph,
    };
