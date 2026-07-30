// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIConfigurationImpl _$$AIConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$AIConfigurationImpl(
      embeddingModelName: json['embeddingModelName'] as String,
      embeddingDimensions: (json['embeddingDimensions'] as num).toInt(),
      embeddingBatchSize: (json['embeddingBatchSize'] as num).toInt(),
      chunkSize: (json['chunkSize'] as num).toInt(),
      chunkOverlap: (json['chunkOverlap'] as num).toInt(),
      inferenceMaxTokens: (json['inferenceMaxTokens'] as num).toInt(),
      inferenceTemperature: (json['inferenceTemperature'] as num).toDouble(),
      inferenceTopP: (json['inferenceTopP'] as num).toDouble(),
      inferenceTopK: (json['inferenceTopK'] as num).toInt(),
      similarityThreshold: (json['similarityThreshold'] as num).toDouble(),
      maxRetrievalResults: (json['maxRetrievalResults'] as num).toInt(),
      cacheEnabled: json['cacheEnabled'] as bool? ?? true,
      cacheSize: (json['cacheSize'] as num).toInt(),
      backgroundWorkers: (json['backgroundWorkers'] as num).toInt(),
      loggingEnabled: json['loggingEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$AIConfigurationImplToJson(
        _$AIConfigurationImpl instance) =>
    <String, dynamic>{
      'embeddingModelName': instance.embeddingModelName,
      'embeddingDimensions': instance.embeddingDimensions,
      'embeddingBatchSize': instance.embeddingBatchSize,
      'chunkSize': instance.chunkSize,
      'chunkOverlap': instance.chunkOverlap,
      'inferenceMaxTokens': instance.inferenceMaxTokens,
      'inferenceTemperature': instance.inferenceTemperature,
      'inferenceTopP': instance.inferenceTopP,
      'inferenceTopK': instance.inferenceTopK,
      'similarityThreshold': instance.similarityThreshold,
      'maxRetrievalResults': instance.maxRetrievalResults,
      'cacheEnabled': instance.cacheEnabled,
      'cacheSize': instance.cacheSize,
      'backgroundWorkers': instance.backgroundWorkers,
      'loggingEnabled': instance.loggingEnabled,
    };
