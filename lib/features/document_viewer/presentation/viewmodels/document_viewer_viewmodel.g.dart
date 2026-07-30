// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_viewer_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentViewerViewModelHash() =>
    r'1a4e818de8d4f04535ebeaae06512fbda2e4506e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DocumentViewerViewModel
    extends BuildlessAutoDisposeAsyncNotifier<DocumentViewerViewModelState> {
  late final String documentId;

  FutureOr<DocumentViewerViewModelState> build(
    String documentId,
  );
}

/// See also [DocumentViewerViewModel].
@ProviderFor(DocumentViewerViewModel)
const documentViewerViewModelProvider = DocumentViewerViewModelFamily();

/// See also [DocumentViewerViewModel].
class DocumentViewerViewModelFamily
    extends Family<AsyncValue<DocumentViewerViewModelState>> {
  /// See also [DocumentViewerViewModel].
  const DocumentViewerViewModelFamily();

  /// See also [DocumentViewerViewModel].
  DocumentViewerViewModelProvider call(
    String documentId,
  ) {
    return DocumentViewerViewModelProvider(
      documentId,
    );
  }

  @override
  DocumentViewerViewModelProvider getProviderOverride(
    covariant DocumentViewerViewModelProvider provider,
  ) {
    return call(
      provider.documentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentViewerViewModelProvider';
}

/// See also [DocumentViewerViewModel].
class DocumentViewerViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DocumentViewerViewModel,
        DocumentViewerViewModelState> {
  /// See also [DocumentViewerViewModel].
  DocumentViewerViewModelProvider(
    String documentId,
  ) : this._internal(
          () => DocumentViewerViewModel()..documentId = documentId,
          from: documentViewerViewModelProvider,
          name: r'documentViewerViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$documentViewerViewModelHash,
          dependencies: DocumentViewerViewModelFamily._dependencies,
          allTransitiveDependencies:
              DocumentViewerViewModelFamily._allTransitiveDependencies,
          documentId: documentId,
        );

  DocumentViewerViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.documentId,
  }) : super.internal();

  final String documentId;

  @override
  FutureOr<DocumentViewerViewModelState> runNotifierBuild(
    covariant DocumentViewerViewModel notifier,
  ) {
    return notifier.build(
      documentId,
    );
  }

  @override
  Override overrideWith(DocumentViewerViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: DocumentViewerViewModelProvider._internal(
        () => create()..documentId = documentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        documentId: documentId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DocumentViewerViewModel,
      DocumentViewerViewModelState> createElement() {
    return _DocumentViewerViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentViewerViewModelProvider &&
        other.documentId == documentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, documentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentViewerViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<DocumentViewerViewModelState> {
  /// The parameter `documentId` of this provider.
  String get documentId;
}

class _DocumentViewerViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DocumentViewerViewModel,
        DocumentViewerViewModelState> with DocumentViewerViewModelRef {
  _DocumentViewerViewModelProviderElement(super.provider);

  @override
  String get documentId =>
      (origin as DocumentViewerViewModelProvider).documentId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
