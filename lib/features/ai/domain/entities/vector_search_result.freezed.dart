// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vector_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VectorSearchResult _$VectorSearchResultFromJson(Map<String, dynamic> json) {
  return _VectorSearchResult.fromJson(json);
}

/// @nodoc
mixin _$VectorSearchResult {
  String get vectorId => throw _privateConstructorUsedError;
  double get similarityScore => throw _privateConstructorUsedError;
  String get documentId => throw _privateConstructorUsedError;
  String get workspaceId => throw _privateConstructorUsedError;
  String get chunkId => throw _privateConstructorUsedError;
  int? get pageNumber => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this VectorSearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VectorSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VectorSearchResultCopyWith<VectorSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VectorSearchResultCopyWith<$Res> {
  factory $VectorSearchResultCopyWith(
          VectorSearchResult value, $Res Function(VectorSearchResult) then) =
      _$VectorSearchResultCopyWithImpl<$Res, VectorSearchResult>;
  @useResult
  $Res call(
      {String vectorId,
      double similarityScore,
      String documentId,
      String workspaceId,
      String chunkId,
      int? pageNumber,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$VectorSearchResultCopyWithImpl<$Res, $Val extends VectorSearchResult>
    implements $VectorSearchResultCopyWith<$Res> {
  _$VectorSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VectorSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vectorId = null,
    Object? similarityScore = null,
    Object? documentId = null,
    Object? workspaceId = null,
    Object? chunkId = null,
    Object? pageNumber = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      vectorId: null == vectorId
          ? _value.vectorId
          : vectorId // ignore: cast_nullable_to_non_nullable
              as String,
      similarityScore: null == similarityScore
          ? _value.similarityScore
          : similarityScore // ignore: cast_nullable_to_non_nullable
              as double,
      documentId: null == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      workspaceId: null == workspaceId
          ? _value.workspaceId
          : workspaceId // ignore: cast_nullable_to_non_nullable
              as String,
      chunkId: null == chunkId
          ? _value.chunkId
          : chunkId // ignore: cast_nullable_to_non_nullable
              as String,
      pageNumber: freezed == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VectorSearchResultImplCopyWith<$Res>
    implements $VectorSearchResultCopyWith<$Res> {
  factory _$$VectorSearchResultImplCopyWith(_$VectorSearchResultImpl value,
          $Res Function(_$VectorSearchResultImpl) then) =
      __$$VectorSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String vectorId,
      double similarityScore,
      String documentId,
      String workspaceId,
      String chunkId,
      int? pageNumber,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$VectorSearchResultImplCopyWithImpl<$Res>
    extends _$VectorSearchResultCopyWithImpl<$Res, _$VectorSearchResultImpl>
    implements _$$VectorSearchResultImplCopyWith<$Res> {
  __$$VectorSearchResultImplCopyWithImpl(_$VectorSearchResultImpl _value,
      $Res Function(_$VectorSearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of VectorSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vectorId = null,
    Object? similarityScore = null,
    Object? documentId = null,
    Object? workspaceId = null,
    Object? chunkId = null,
    Object? pageNumber = freezed,
    Object? metadata = null,
  }) {
    return _then(_$VectorSearchResultImpl(
      vectorId: null == vectorId
          ? _value.vectorId
          : vectorId // ignore: cast_nullable_to_non_nullable
              as String,
      similarityScore: null == similarityScore
          ? _value.similarityScore
          : similarityScore // ignore: cast_nullable_to_non_nullable
              as double,
      documentId: null == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      workspaceId: null == workspaceId
          ? _value.workspaceId
          : workspaceId // ignore: cast_nullable_to_non_nullable
              as String,
      chunkId: null == chunkId
          ? _value.chunkId
          : chunkId // ignore: cast_nullable_to_non_nullable
              as String,
      pageNumber: freezed == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VectorSearchResultImpl implements _VectorSearchResult {
  const _$VectorSearchResultImpl(
      {required this.vectorId,
      required this.similarityScore,
      required this.documentId,
      required this.workspaceId,
      required this.chunkId,
      this.pageNumber,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$VectorSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$VectorSearchResultImplFromJson(json);

  @override
  final String vectorId;
  @override
  final double similarityScore;
  @override
  final String documentId;
  @override
  final String workspaceId;
  @override
  final String chunkId;
  @override
  final int? pageNumber;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'VectorSearchResult(vectorId: $vectorId, similarityScore: $similarityScore, documentId: $documentId, workspaceId: $workspaceId, chunkId: $chunkId, pageNumber: $pageNumber, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VectorSearchResultImpl &&
            (identical(other.vectorId, vectorId) ||
                other.vectorId == vectorId) &&
            (identical(other.similarityScore, similarityScore) ||
                other.similarityScore == similarityScore) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.workspaceId, workspaceId) ||
                other.workspaceId == workspaceId) &&
            (identical(other.chunkId, chunkId) || other.chunkId == chunkId) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      vectorId,
      similarityScore,
      documentId,
      workspaceId,
      chunkId,
      pageNumber,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of VectorSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VectorSearchResultImplCopyWith<_$VectorSearchResultImpl> get copyWith =>
      __$$VectorSearchResultImplCopyWithImpl<_$VectorSearchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VectorSearchResultImplToJson(
      this,
    );
  }
}

abstract class _VectorSearchResult implements VectorSearchResult {
  const factory _VectorSearchResult(
      {required final String vectorId,
      required final double similarityScore,
      required final String documentId,
      required final String workspaceId,
      required final String chunkId,
      final int? pageNumber,
      final Map<String, dynamic> metadata}) = _$VectorSearchResultImpl;

  factory _VectorSearchResult.fromJson(Map<String, dynamic> json) =
      _$VectorSearchResultImpl.fromJson;

  @override
  String get vectorId;
  @override
  double get similarityScore;
  @override
  String get documentId;
  @override
  String get workspaceId;
  @override
  String get chunkId;
  @override
  int? get pageNumber;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of VectorSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VectorSearchResultImplCopyWith<_$VectorSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
