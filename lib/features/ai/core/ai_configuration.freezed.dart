// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIConfiguration _$AIConfigurationFromJson(Map<String, dynamic> json) {
  return _AIConfiguration.fromJson(json);
}

/// @nodoc
mixin _$AIConfiguration {
// Embedding configuration
  String get embeddingModelName => throw _privateConstructorUsedError;
  int get embeddingDimensions => throw _privateConstructorUsedError;
  int get embeddingBatchSize =>
      throw _privateConstructorUsedError; // Chunking configuration
  int get chunkSize => throw _privateConstructorUsedError;
  int get chunkOverlap =>
      throw _privateConstructorUsedError; // Inference configuration
  int get inferenceMaxTokens => throw _privateConstructorUsedError;
  double get inferenceTemperature => throw _privateConstructorUsedError;
  double get inferenceTopP => throw _privateConstructorUsedError;
  int get inferenceTopK =>
      throw _privateConstructorUsedError; // Retrieval configuration
  double get similarityThreshold => throw _privateConstructorUsedError;
  int get maxRetrievalResults =>
      throw _privateConstructorUsedError; // Performance configuration
  bool get cacheEnabled => throw _privateConstructorUsedError;
  int get cacheSize => throw _privateConstructorUsedError;
  int get backgroundWorkers =>
      throw _privateConstructorUsedError; // Debug configuration
  bool get loggingEnabled => throw _privateConstructorUsedError;

  /// Serializes this AIConfiguration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConfigurationCopyWith<AIConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConfigurationCopyWith<$Res> {
  factory $AIConfigurationCopyWith(
          AIConfiguration value, $Res Function(AIConfiguration) then) =
      _$AIConfigurationCopyWithImpl<$Res, AIConfiguration>;
  @useResult
  $Res call(
      {String embeddingModelName,
      int embeddingDimensions,
      int embeddingBatchSize,
      int chunkSize,
      int chunkOverlap,
      int inferenceMaxTokens,
      double inferenceTemperature,
      double inferenceTopP,
      int inferenceTopK,
      double similarityThreshold,
      int maxRetrievalResults,
      bool cacheEnabled,
      int cacheSize,
      int backgroundWorkers,
      bool loggingEnabled});
}

/// @nodoc
class _$AIConfigurationCopyWithImpl<$Res, $Val extends AIConfiguration>
    implements $AIConfigurationCopyWith<$Res> {
  _$AIConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? embeddingModelName = null,
    Object? embeddingDimensions = null,
    Object? embeddingBatchSize = null,
    Object? chunkSize = null,
    Object? chunkOverlap = null,
    Object? inferenceMaxTokens = null,
    Object? inferenceTemperature = null,
    Object? inferenceTopP = null,
    Object? inferenceTopK = null,
    Object? similarityThreshold = null,
    Object? maxRetrievalResults = null,
    Object? cacheEnabled = null,
    Object? cacheSize = null,
    Object? backgroundWorkers = null,
    Object? loggingEnabled = null,
  }) {
    return _then(_value.copyWith(
      embeddingModelName: null == embeddingModelName
          ? _value.embeddingModelName
          : embeddingModelName // ignore: cast_nullable_to_non_nullable
              as String,
      embeddingDimensions: null == embeddingDimensions
          ? _value.embeddingDimensions
          : embeddingDimensions // ignore: cast_nullable_to_non_nullable
              as int,
      embeddingBatchSize: null == embeddingBatchSize
          ? _value.embeddingBatchSize
          : embeddingBatchSize // ignore: cast_nullable_to_non_nullable
              as int,
      chunkSize: null == chunkSize
          ? _value.chunkSize
          : chunkSize // ignore: cast_nullable_to_non_nullable
              as int,
      chunkOverlap: null == chunkOverlap
          ? _value.chunkOverlap
          : chunkOverlap // ignore: cast_nullable_to_non_nullable
              as int,
      inferenceMaxTokens: null == inferenceMaxTokens
          ? _value.inferenceMaxTokens
          : inferenceMaxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      inferenceTemperature: null == inferenceTemperature
          ? _value.inferenceTemperature
          : inferenceTemperature // ignore: cast_nullable_to_non_nullable
              as double,
      inferenceTopP: null == inferenceTopP
          ? _value.inferenceTopP
          : inferenceTopP // ignore: cast_nullable_to_non_nullable
              as double,
      inferenceTopK: null == inferenceTopK
          ? _value.inferenceTopK
          : inferenceTopK // ignore: cast_nullable_to_non_nullable
              as int,
      similarityThreshold: null == similarityThreshold
          ? _value.similarityThreshold
          : similarityThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      maxRetrievalResults: null == maxRetrievalResults
          ? _value.maxRetrievalResults
          : maxRetrievalResults // ignore: cast_nullable_to_non_nullable
              as int,
      cacheEnabled: null == cacheEnabled
          ? _value.cacheEnabled
          : cacheEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      cacheSize: null == cacheSize
          ? _value.cacheSize
          : cacheSize // ignore: cast_nullable_to_non_nullable
              as int,
      backgroundWorkers: null == backgroundWorkers
          ? _value.backgroundWorkers
          : backgroundWorkers // ignore: cast_nullable_to_non_nullable
              as int,
      loggingEnabled: null == loggingEnabled
          ? _value.loggingEnabled
          : loggingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIConfigurationImplCopyWith<$Res>
    implements $AIConfigurationCopyWith<$Res> {
  factory _$$AIConfigurationImplCopyWith(_$AIConfigurationImpl value,
          $Res Function(_$AIConfigurationImpl) then) =
      __$$AIConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String embeddingModelName,
      int embeddingDimensions,
      int embeddingBatchSize,
      int chunkSize,
      int chunkOverlap,
      int inferenceMaxTokens,
      double inferenceTemperature,
      double inferenceTopP,
      int inferenceTopK,
      double similarityThreshold,
      int maxRetrievalResults,
      bool cacheEnabled,
      int cacheSize,
      int backgroundWorkers,
      bool loggingEnabled});
}

/// @nodoc
class __$$AIConfigurationImplCopyWithImpl<$Res>
    extends _$AIConfigurationCopyWithImpl<$Res, _$AIConfigurationImpl>
    implements _$$AIConfigurationImplCopyWith<$Res> {
  __$$AIConfigurationImplCopyWithImpl(
      _$AIConfigurationImpl _value, $Res Function(_$AIConfigurationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? embeddingModelName = null,
    Object? embeddingDimensions = null,
    Object? embeddingBatchSize = null,
    Object? chunkSize = null,
    Object? chunkOverlap = null,
    Object? inferenceMaxTokens = null,
    Object? inferenceTemperature = null,
    Object? inferenceTopP = null,
    Object? inferenceTopK = null,
    Object? similarityThreshold = null,
    Object? maxRetrievalResults = null,
    Object? cacheEnabled = null,
    Object? cacheSize = null,
    Object? backgroundWorkers = null,
    Object? loggingEnabled = null,
  }) {
    return _then(_$AIConfigurationImpl(
      embeddingModelName: null == embeddingModelName
          ? _value.embeddingModelName
          : embeddingModelName // ignore: cast_nullable_to_non_nullable
              as String,
      embeddingDimensions: null == embeddingDimensions
          ? _value.embeddingDimensions
          : embeddingDimensions // ignore: cast_nullable_to_non_nullable
              as int,
      embeddingBatchSize: null == embeddingBatchSize
          ? _value.embeddingBatchSize
          : embeddingBatchSize // ignore: cast_nullable_to_non_nullable
              as int,
      chunkSize: null == chunkSize
          ? _value.chunkSize
          : chunkSize // ignore: cast_nullable_to_non_nullable
              as int,
      chunkOverlap: null == chunkOverlap
          ? _value.chunkOverlap
          : chunkOverlap // ignore: cast_nullable_to_non_nullable
              as int,
      inferenceMaxTokens: null == inferenceMaxTokens
          ? _value.inferenceMaxTokens
          : inferenceMaxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      inferenceTemperature: null == inferenceTemperature
          ? _value.inferenceTemperature
          : inferenceTemperature // ignore: cast_nullable_to_non_nullable
              as double,
      inferenceTopP: null == inferenceTopP
          ? _value.inferenceTopP
          : inferenceTopP // ignore: cast_nullable_to_non_nullable
              as double,
      inferenceTopK: null == inferenceTopK
          ? _value.inferenceTopK
          : inferenceTopK // ignore: cast_nullable_to_non_nullable
              as int,
      similarityThreshold: null == similarityThreshold
          ? _value.similarityThreshold
          : similarityThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      maxRetrievalResults: null == maxRetrievalResults
          ? _value.maxRetrievalResults
          : maxRetrievalResults // ignore: cast_nullable_to_non_nullable
              as int,
      cacheEnabled: null == cacheEnabled
          ? _value.cacheEnabled
          : cacheEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      cacheSize: null == cacheSize
          ? _value.cacheSize
          : cacheSize // ignore: cast_nullable_to_non_nullable
              as int,
      backgroundWorkers: null == backgroundWorkers
          ? _value.backgroundWorkers
          : backgroundWorkers // ignore: cast_nullable_to_non_nullable
              as int,
      loggingEnabled: null == loggingEnabled
          ? _value.loggingEnabled
          : loggingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIConfigurationImpl implements _AIConfiguration {
  const _$AIConfigurationImpl(
      {required this.embeddingModelName,
      required this.embeddingDimensions,
      required this.embeddingBatchSize,
      required this.chunkSize,
      required this.chunkOverlap,
      required this.inferenceMaxTokens,
      required this.inferenceTemperature,
      required this.inferenceTopP,
      required this.inferenceTopK,
      required this.similarityThreshold,
      required this.maxRetrievalResults,
      this.cacheEnabled = true,
      required this.cacheSize,
      required this.backgroundWorkers,
      this.loggingEnabled = false});

  factory _$AIConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIConfigurationImplFromJson(json);

// Embedding configuration
  @override
  final String embeddingModelName;
  @override
  final int embeddingDimensions;
  @override
  final int embeddingBatchSize;
// Chunking configuration
  @override
  final int chunkSize;
  @override
  final int chunkOverlap;
// Inference configuration
  @override
  final int inferenceMaxTokens;
  @override
  final double inferenceTemperature;
  @override
  final double inferenceTopP;
  @override
  final int inferenceTopK;
// Retrieval configuration
  @override
  final double similarityThreshold;
  @override
  final int maxRetrievalResults;
// Performance configuration
  @override
  @JsonKey()
  final bool cacheEnabled;
  @override
  final int cacheSize;
  @override
  final int backgroundWorkers;
// Debug configuration
  @override
  @JsonKey()
  final bool loggingEnabled;

  @override
  String toString() {
    return 'AIConfiguration(embeddingModelName: $embeddingModelName, embeddingDimensions: $embeddingDimensions, embeddingBatchSize: $embeddingBatchSize, chunkSize: $chunkSize, chunkOverlap: $chunkOverlap, inferenceMaxTokens: $inferenceMaxTokens, inferenceTemperature: $inferenceTemperature, inferenceTopP: $inferenceTopP, inferenceTopK: $inferenceTopK, similarityThreshold: $similarityThreshold, maxRetrievalResults: $maxRetrievalResults, cacheEnabled: $cacheEnabled, cacheSize: $cacheSize, backgroundWorkers: $backgroundWorkers, loggingEnabled: $loggingEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConfigurationImpl &&
            (identical(other.embeddingModelName, embeddingModelName) ||
                other.embeddingModelName == embeddingModelName) &&
            (identical(other.embeddingDimensions, embeddingDimensions) ||
                other.embeddingDimensions == embeddingDimensions) &&
            (identical(other.embeddingBatchSize, embeddingBatchSize) ||
                other.embeddingBatchSize == embeddingBatchSize) &&
            (identical(other.chunkSize, chunkSize) ||
                other.chunkSize == chunkSize) &&
            (identical(other.chunkOverlap, chunkOverlap) ||
                other.chunkOverlap == chunkOverlap) &&
            (identical(other.inferenceMaxTokens, inferenceMaxTokens) ||
                other.inferenceMaxTokens == inferenceMaxTokens) &&
            (identical(other.inferenceTemperature, inferenceTemperature) ||
                other.inferenceTemperature == inferenceTemperature) &&
            (identical(other.inferenceTopP, inferenceTopP) ||
                other.inferenceTopP == inferenceTopP) &&
            (identical(other.inferenceTopK, inferenceTopK) ||
                other.inferenceTopK == inferenceTopK) &&
            (identical(other.similarityThreshold, similarityThreshold) ||
                other.similarityThreshold == similarityThreshold) &&
            (identical(other.maxRetrievalResults, maxRetrievalResults) ||
                other.maxRetrievalResults == maxRetrievalResults) &&
            (identical(other.cacheEnabled, cacheEnabled) ||
                other.cacheEnabled == cacheEnabled) &&
            (identical(other.cacheSize, cacheSize) ||
                other.cacheSize == cacheSize) &&
            (identical(other.backgroundWorkers, backgroundWorkers) ||
                other.backgroundWorkers == backgroundWorkers) &&
            (identical(other.loggingEnabled, loggingEnabled) ||
                other.loggingEnabled == loggingEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      embeddingModelName,
      embeddingDimensions,
      embeddingBatchSize,
      chunkSize,
      chunkOverlap,
      inferenceMaxTokens,
      inferenceTemperature,
      inferenceTopP,
      inferenceTopK,
      similarityThreshold,
      maxRetrievalResults,
      cacheEnabled,
      cacheSize,
      backgroundWorkers,
      loggingEnabled);

  /// Create a copy of AIConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConfigurationImplCopyWith<_$AIConfigurationImpl> get copyWith =>
      __$$AIConfigurationImplCopyWithImpl<_$AIConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIConfigurationImplToJson(
      this,
    );
  }
}

abstract class _AIConfiguration implements AIConfiguration {
  const factory _AIConfiguration(
      {required final String embeddingModelName,
      required final int embeddingDimensions,
      required final int embeddingBatchSize,
      required final int chunkSize,
      required final int chunkOverlap,
      required final int inferenceMaxTokens,
      required final double inferenceTemperature,
      required final double inferenceTopP,
      required final int inferenceTopK,
      required final double similarityThreshold,
      required final int maxRetrievalResults,
      final bool cacheEnabled,
      required final int cacheSize,
      required final int backgroundWorkers,
      final bool loggingEnabled}) = _$AIConfigurationImpl;

  factory _AIConfiguration.fromJson(Map<String, dynamic> json) =
      _$AIConfigurationImpl.fromJson;

// Embedding configuration
  @override
  String get embeddingModelName;
  @override
  int get embeddingDimensions;
  @override
  int get embeddingBatchSize; // Chunking configuration
  @override
  int get chunkSize;
  @override
  int get chunkOverlap; // Inference configuration
  @override
  int get inferenceMaxTokens;
  @override
  double get inferenceTemperature;
  @override
  double get inferenceTopP;
  @override
  int get inferenceTopK; // Retrieval configuration
  @override
  double get similarityThreshold;
  @override
  int get maxRetrievalResults; // Performance configuration
  @override
  bool get cacheEnabled;
  @override
  int get cacheSize;
  @override
  int get backgroundWorkers; // Debug configuration
  @override
  bool get loggingEnabled;

  /// Create a copy of AIConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConfigurationImplCopyWith<_$AIConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
