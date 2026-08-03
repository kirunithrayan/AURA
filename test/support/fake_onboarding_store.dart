import 'package:aura/features/onboarding/domain/services/onboarding_store.dart';

/// In-memory [OnboardingStore] for widget tests.
///
/// Keeps storage out of widget tests entirely: no platform channels, no
/// plugin registration, no real keystore.
class FakeOnboardingStore implements OnboardingStore {
  FakeOnboardingStore({this.complete = false});

  /// Current value of the persisted flag.
  bool complete;

  /// How many times [markOnboardingComplete] was called.
  int markCallCount = 0;

  @override
  Future<bool> isOnboardingComplete() async => complete;

  @override
  Future<void> markOnboardingComplete() async {
    markCallCount++;
    complete = true;
  }
}

/// [OnboardingStore] that violates the "never throws" contract, used to prove
/// the UI still navigates when a misbehaving implementation is injected.
class ThrowingOnboardingStore implements OnboardingStore {
  @override
  Future<bool> isOnboardingComplete() async =>
      throw StateError('read failed');

  @override
  Future<void> markOnboardingComplete() async =>
      throw StateError('write failed');
}
