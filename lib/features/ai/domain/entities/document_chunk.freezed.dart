// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_chunk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentChunk _$DocumentChunkFromJson(Map<String, dynamic> json) {
  return _DocumentChunk.fromJson(json);
}

/// @nodoc
mixin _$DocumentChunk {
  String get id => throw _privateConstructorUsedError;
  String get documentId => throw _privateConstructorUsedError;
  String get workspaceId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  int get chunkIndex => throw _privateConstructorUsedError;
  int? get pageNumber => throw _privateConstructorUsedError;
  int? get startOffset => throw _privateConstructorUsedError;
  int? get endOffset => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this DocumentChunk to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentChunkCopyWith<DocumentChunk> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentChunkCopyWith<$Res> {
  factory $DocumentChunkCopyWith(
          DocumentChunk value, $Res Function(DocumentChunk) then) =
      _$DocumentChunkCopyWithImpl<$Res, DocumentChunk>;
  @useResult
  $Res call(
      {String id,
      String documentId,
      String workspaceId,
      String text,
      int chunkIndex,
      int? pageNumber,
      int? startOffset,
      int? endOffset,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$DocumentChunkCopyWithImpl<$Res, $Val extends DocumentChunk>
    implements $DocumentChunkCopyWith<$Res> {
  _$DocumentChunkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentId = null,
    Object? workspaceId = null,
    Object? text = null,
    Object? chunkIndex = null,
    Object? pageNumber = freezed,
    Object? startOffset = freezed,
    Object? endOffset = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      documentId: null == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      workspaceId: null == workspaceId
          ? _value.workspaceId
          : workspaceId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      chunkIndex: null == chunkIndex
          ? _value.chunkIndex
          : chunkIndex // ignore: cast_nullable_to_non_nullable
              as int,
      pageNumber: freezed == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      startOffset: freezed == startOffset
          ? _value.startOffset
          : startOffset // ignore: cast_nullable_to_non_nullable
              as int?,
      endOffset: freezed == endOffset
          ? _value.endOffset
          : endOffset // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentChunkImplCopyWith<$Res>
    implements $DocumentChunkCopyWith<$Res> {
  factory _$$DocumentChunkImplCopyWith(
          _$DocumentChunkImpl value, $Res Function(_$DocumentChunkImpl) then) =
      __$$DocumentChunkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String documentId,
      String workspaceId,
      String text,
      int chunkIndex,
      int? pageNumber,
      int? startOffset,
      int? endOffset,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$DocumentChunkImplCopyWithImpl<$Res>
    extends _$DocumentChunkCopyWithImpl<$Res, _$DocumentChunkImpl>
    implements _$$DocumentChunkImplCopyWith<$Res> {
  __$$DocumentChunkImplCopyWithImpl(
      _$DocumentChunkImpl _value, $Res Function(_$DocumentChunkImpl) _then)
      : super(_value, _then);

  /// Create a copy of DocumentChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentId = null,
    Object? workspaceId = null,
    Object? text = null,
    Object? chunkIndex = null,
    Object? pageNumber = freezed,
    Object? startOffset = freezed,
    Object? endOffset = freezed,
    Object? metadata = null,
  }) {
    return _then(_$DocumentChunkImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      documentId: null == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as String,
      workspaceId: null == workspaceId
          ? _value.workspaceId
          : workspaceId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      chunkIndex: null == chunkIndex
          ? _value.chunkIndex
          : chunkIndex // ignore: cast_nullable_to_non_nullable
              as int,
      pageNumber: freezed == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      startOffset: freezed == startOffset
          ? _value.startOffset
          : startOffset // ignore: cast_nullable_to_non_nullable
              as int?,
      endOffset: freezed == endOffset
          ? _value.endOffset
          : endOffset // ignore: cast_nullable_to_non_nullable
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
class _$DocumentChunkImpl implements _DocumentChunk {
  const _$DocumentChunkImpl(
      {required this.id,
      required this.documentId,
      required this.workspaceId,
      required this.text,
      required this.chunkIndex,
      this.pageNumber,
      this.startOffset,
      this.endOffset,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$DocumentChunkImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentChunkImplFromJson(json);

  @override
  final String id;
  @override
  final String documentId;
  @override
  final String workspaceId;
  @override
  final String text;
  @override
  final int chunkIndex;
  @override
  final int? pageNumber;
  @override
  final int? startOffset;
  @override
  final int? endOffset;
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
    return 'DocumentChunk(id: $id, documentId: $documentId, workspaceId: $workspaceId, text: $text, chunkIndex: $chunkIndex, pageNumber: $pageNumber, startOffset: $startOffset, endOffset: $endOffset, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentChunkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.workspaceId, workspaceId) ||
                other.workspaceId == workspaceId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.chunkIndex, chunkIndex) ||
                other.chunkIndex == chunkIndex) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.startOffset, startOffset) ||
                other.startOffset == startOffset) &&
            (identical(other.endOffset, endOffset) ||
                other.endOffset == endOffset) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      documentId,
      workspaceId,
      text,
      chunkIndex,
      pageNumber,
      startOffset,
      endOffset,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of DocumentChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentChunkImplCopyWith<_$DocumentChunkImpl> get copyWith =>
      __$$DocumentChunkImplCopyWithImpl<_$DocumentChunkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentChunkImplToJson(
      this,
    );
  }
}

abstract class _DocumentChunk implements DocumentChunk {
  const factory _DocumentChunk(
      {required final String id,
      required final String documentId,
      required final String workspaceId,
      required final String text,
      required final int chunkIndex,
      final int? pageNumber,
      final int? startOffset,
      final int? endOffset,
      final Map<String, dynamic> metadata}) = _$DocumentChunkImpl;

  factory _DocumentChunk.fromJson(Map<String, dynamic> json) =
      _$DocumentChunkImpl.fromJson;

  @override
  String get id;
  @override
  String get documentId;
  @override
  String get workspaceId;
  @override
  String get text;
  @override
  int get chunkIndex;
  @override
  int? get pageNumber;
  @override
  int? get startOffset;
  @override
  int? get endOffset;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of DocumentChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentChunkImplCopyWith<_$DocumentChunkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
