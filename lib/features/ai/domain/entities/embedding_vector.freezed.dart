// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_vector.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EmbeddingVector _$EmbeddingVectorFromJson(Map<String, dynamic> json) {
  return _EmbeddingVector.fromJson(json);
}

/// @nodoc
mixin _$EmbeddingVector {
  String get id => throw _privateConstructorUsedError;
  List<double> get values => throw _privateConstructorUsedError;
  int get dimensions => throw _privateConstructorUsedError;
  String get modelName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this EmbeddingVector to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmbeddingVector
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmbeddingVectorCopyWith<EmbeddingVector> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmbeddingVectorCopyWith<$Res> {
  factory $EmbeddingVectorCopyWith(
          EmbeddingVector value, $Res Function(EmbeddingVector) then) =
      _$EmbeddingVectorCopyWithImpl<$Res, EmbeddingVector>;
  @useResult
  $Res call(
      {String id,
      List<double> values,
      int dimensions,
      String modelName,
      DateTime createdAt});
}

/// @nodoc
class _$EmbeddingVectorCopyWithImpl<$Res, $Val extends EmbeddingVector>
    implements $EmbeddingVectorCopyWith<$Res> {
  _$EmbeddingVectorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmbeddingVector
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? values = null,
    Object? dimensions = null,
    Object? modelName = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      values: null == values
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as List<double>,
      dimensions: null == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as int,
      modelName: null == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmbeddingVectorImplCopyWith<$Res>
    implements $EmbeddingVectorCopyWith<$Res> {
  factory _$$EmbeddingVectorImplCopyWith(_$EmbeddingVectorImpl value,
          $Res Function(_$EmbeddingVectorImpl) then) =
      __$$EmbeddingVectorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<double> values,
      int dimensions,
      String modelName,
      DateTime createdAt});
}

/// @nodoc
class __$$EmbeddingVectorImplCopyWithImpl<$Res>
    extends _$EmbeddingVectorCopyWithImpl<$Res, _$EmbeddingVectorImpl>
    implements _$$EmbeddingVectorImplCopyWith<$Res> {
  __$$EmbeddingVectorImplCopyWithImpl(
      _$EmbeddingVectorImpl _value, $Res Function(_$EmbeddingVectorImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmbeddingVector
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? values = null,
    Object? dimensions = null,
    Object? modelName = null,
    Object? createdAt = null,
  }) {
    return _then(_$EmbeddingVectorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<double>,
      dimensions: null == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as int,
      modelName: null == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmbeddingVectorImpl implements _EmbeddingVector {
  const _$EmbeddingVectorImpl(
      {required this.id,
      required final List<double> values,
      required this.dimensions,
      required this.modelName,
      required this.createdAt})
      : _values = values;

  factory _$EmbeddingVectorImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmbeddingVectorImplFromJson(json);

  @override
  final String id;
  final List<double> _values;
  @override
  List<double> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  final int dimensions;
  @override
  final String modelName;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'EmbeddingVector(id: $id, values: $values, dimensions: $dimensions, modelName: $modelName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmbeddingVectorImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            (identical(other.dimensions, dimensions) ||
                other.dimensions == dimensions) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_values),
      dimensions,
      modelName,
      createdAt);

  /// Create a copy of EmbeddingVector
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmbeddingVectorImplCopyWith<_$EmbeddingVectorImpl> get copyWith =>
      __$$EmbeddingVectorImplCopyWithImpl<_$EmbeddingVectorImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmbeddingVectorImplToJson(
      this,
    );
  }
}

abstract class _EmbeddingVector implements EmbeddingVector {
  const factory _EmbeddingVector(
      {required final String id,
      required final List<double> values,
      required final int dimensions,
      required final String modelName,
      required final DateTime createdAt}) = _$EmbeddingVectorImpl;

  factory _EmbeddingVector.fromJson(Map<String, dynamic> json) =
      _$EmbeddingVectorImpl.fromJson;

  @override
  String get id;
  @override
  List<double> get values;
  @override
  int get dimensions;
  @override
  String get modelName;
  @override
  DateTime get createdAt;

  /// Create a copy of EmbeddingVector
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmbeddingVectorImplCopyWith<_$EmbeddingVectorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
