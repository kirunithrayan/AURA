// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_vector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmbeddingVectorImpl _$$EmbeddingVectorImplFromJson(
        Map<String, dynamic> json) =>
    _$EmbeddingVectorImpl(
      id: json['id'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      dimensions: (json['dimensions'] as num).toInt(),
      modelName: json['modelName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EmbeddingVectorImplToJson(
        _$EmbeddingVectorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'values': instance.values,
      'dimensions': instance.dimensions,
      'modelName': instance.modelName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
