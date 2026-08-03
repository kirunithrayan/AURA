import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/services/onboarding_store.dart';

/// [OnboardingStore] backed by platform secure storage (Keystore on Android).
///
/// Both operations are deliberately total: a locked, corrupt or unavailable
/// keystore resolves to "onboarding not complete" instead of propagating an
/// error into app startup.
class SecureOnboardingStore implements OnboardingStore {
  SecureOnboardingStore(this._storage);

  /// The single definition of the persisted key.
  ///
  /// Nothing else in the app should repeat this literal: read it from here.
  static const String onboardingCompleteKey = 'onboarding_complete';

  /// The only value treated as "complete". Anything else means not complete.
  static const String completedValue = 'true';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      final String? value = await _storage.read(key: onboardingCompleteKey);
      return value == completedValue;
    } catch (_) {
      // Intentionally broad. A platform-channel failure, a locked keystore or
      // a decryption error must not stop the app from starting. Falling back
      // to false re-shows onboarding, which is harmless and recoverable.
      return false;
    }
  }

  @override
  Future<void> markOnboardingComplete() async {
    try {
      await _storage.write(
        key: onboardingCompleteKey,
        value: completedValue,
      );
    } catch (_) {
      // Intentionally broad, same reasoning as above: failing to persist must
      // never trap the user on the onboarding screen. They simply see it once
      // more next launch.
    }
  }
}
