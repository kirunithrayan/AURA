// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workspaceDetailViewModelHash() =>
    r'ebaae008b767808085a4318c2c8464d9d87cf58e';

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

abstract class _$WorkspaceDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<WorkspaceDetailState> {
  late final String workspaceId;

  FutureOr<WorkspaceDetailState> build(
    String workspaceId,
  );
}

/// See also [WorkspaceDetailViewModel].
@ProviderFor(WorkspaceDetailViewModel)
const workspaceDetailViewModelProvider = WorkspaceDetailViewModelFamily();

/// See also [WorkspaceDetailViewModel].
class WorkspaceDetailViewModelFamily
    extends Family<AsyncValue<WorkspaceDetailState>> {
  /// See also [WorkspaceDetailViewModel].
  const WorkspaceDetailViewModelFamily();

  /// See also [WorkspaceDetailViewModel].
  WorkspaceDetailViewModelProvider call(
    String workspaceId,
  ) {
    return WorkspaceDetailViewModelProvider(
      workspaceId,
    );
  }

  @override
  WorkspaceDetailViewModelProvider getProviderOverride(
    covariant WorkspaceDetailViewModelProvider provider,
  ) {
    return call(
      provider.workspaceId,
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
  String? get name => r'workspaceDetailViewModelProvider';
}

/// See also [WorkspaceDetailViewModel].
class WorkspaceDetailViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WorkspaceDetailViewModel,
        WorkspaceDetailState> {
  /// See also [WorkspaceDetailViewModel].
  WorkspaceDetailViewModelProvider(
    String workspaceId,
  ) : this._internal(
          () => WorkspaceDetailViewModel()..workspaceId = workspaceId,
          from: workspaceDetailViewModelProvider,
          name: r'workspaceDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$workspaceDetailViewModelHash,
          dependencies: WorkspaceDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              WorkspaceDetailViewModelFamily._allTransitiveDependencies,
          workspaceId: workspaceId,
        );

  WorkspaceDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.workspaceId,
  }) : super.internal();

  final String workspaceId;

  @override
  FutureOr<WorkspaceDetailState> runNotifierBuild(
    covariant WorkspaceDetailViewModel notifier,
  ) {
    return notifier.build(
      workspaceId,
    );
  }

  @override
  Override overrideWith(WorkspaceDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkspaceDetailViewModelProvider._internal(
        () => create()..workspaceId = workspaceId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        workspaceId: workspaceId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<WorkspaceDetailViewModel,
      WorkspaceDetailState> createElement() {
    return _WorkspaceDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkspaceDetailViewModelProvider &&
        other.workspaceId == workspaceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, workspaceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkspaceDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<WorkspaceDetailState> {
  /// The parameter `workspaceId` of this provider.
  String get workspaceId;
}

class _WorkspaceDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WorkspaceDetailViewModel,
        WorkspaceDetailState> with WorkspaceDetailViewModelRef {
  _WorkspaceDetailViewModelProviderElement(super.provider);

  @override
  String get workspaceId =>
      (origin as WorkspaceDetailViewModelProvider).workspaceId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
