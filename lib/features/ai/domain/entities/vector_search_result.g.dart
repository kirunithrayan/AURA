// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vector_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VectorSearchResultImpl _$$VectorSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$VectorSearchResultImpl(
      vectorId: json['vectorId'] as String,
      similarityScore: (json['similarityScore'] as num).toDouble(),
      documentId: json['documentId'] as String,
      workspaceId: json['workspaceId'] as String,
      chunkId: json['chunkId'] as String,
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$VectorSearchResultImplToJson(
        _$VectorSearchResultImpl instance) =>
    <String, dynamic>{
      'vectorId': instance.vectorId,
      'similarityScore': instance.similarityScore,
      'documentId': instance.documentId,
      'workspaceId': instance.workspaceId,
      'chunkId': instance.chunkId,
      'pageNumber': instance.pageNumber,
      'metadata': instance.metadata,
    };
