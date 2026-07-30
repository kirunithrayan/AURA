import 'package:freezed_annotation/freezed_annotation.dart';

part 'embedding_vector.freezed.dart';
part 'embedding_vector.g.dart';

/// Strongly typed immutable domain entity representing an embedding vector.
@freezed
class EmbeddingVector with _$EmbeddingVector {
  const factory EmbeddingVector({
    required String id,
    required List<double> values,
    required int dimensions,
    required String modelName,
    required DateTime createdAt,
  }) = _EmbeddingVector;

  factory EmbeddingVector.fromJson(Map<String, dynamic> json) => _$EmbeddingVectorFromJson(json);
}
