// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_chunk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentChunkImpl _$$DocumentChunkImplFromJson(Map<String, dynamic> json) =>
    _$DocumentChunkImpl(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      workspaceId: json['workspaceId'] as String,
      text: json['text'] as String,
      chunkIndex: (json['chunkIndex'] as num).toInt(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      startOffset: (json['startOffset'] as num?)?.toInt(),
      endOffset: (json['endOffset'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DocumentChunkImplToJson(_$DocumentChunkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentId': instance.documentId,
      'workspaceId': instance.workspaceId,
      'text': instance.text,
      'chunkIndex': instance.chunkIndex,
      'pageNumber': instance.pageNumber,
      'startOffset': instance.startOffset,
      'endOffset': instance.endOffset,
      'metadata': instance.metadata,
    };
