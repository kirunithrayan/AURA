import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/onboarding/data/services/secure_onboarding_store.dart';

/// Minimal in-memory [FlutterSecureStorage] stand-in.
///
/// Only [read] and [write] are exercised; anything else throws via
/// [noSuchMethod], which keeps the fake honest if the store starts calling
/// something new.
class _FakeSecureStorage implements FlutterSecureStorage {
  _FakeSecureStorage({this.throwOnRead = false, this.throwOnWrite = false});

  final Map<String, String?> values = <String, String?>{};
  final bool throwOnRead;
  final bool throwOnWrite;

  int readCount = 0;
  int writeCount = 0;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    readCount++;
    if (throwOnRead) {
      throw PlatformException(code: 'keystore_locked');
    }
    return values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    writeCount++;
    if (throwOnWrite) {
      throw PlatformException(code: 'keystore_readonly');
    }
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SecureOnboardingStore', () {
    test('reports not complete on a fresh install', () async {
      final store = SecureOnboardingStore(_FakeSecureStorage());

      expect(await store.isOnboardingComplete(), isFalse);
    });

    test('reports complete after the flag is written', () async {
      final store = SecureOnboardingStore(_FakeSecureStorage());

      await store.markOnboardingComplete();

      expect(await store.isOnboardingComplete(), isTrue);
    });

    test('writes the documented value under the documented key', () async {
      final storage = _FakeSecureStorage();
      final store = SecureOnboardingStore(storage);

      await store.markOnboardingComplete();

      expect(
        storage.values[SecureOnboardingStore.onboardingCompleteKey],
        SecureOnboardingStore.completedValue,
      );
    });

    test('key constant is stable', () {
      // Changing this silently re-shows onboarding for every existing user.
      expect(
        SecureOnboardingStore.onboardingCompleteKey,
        'onboarding_complete',
      );
    });

    test('treats any unexpected stored value as not complete', () async {
      final storage = _FakeSecureStorage();
      storage.values[SecureOnboardingStore.onboardingCompleteKey] = 'yes';
      final store = SecureOnboardingStore(storage);

      expect(await store.isOnboardingComplete(), isFalse);
    });

    test('is idempotent across repeated completion', () async {
      final storage = _FakeSecureStorage();
      final store = SecureOnboardingStore(storage);

      await store.markOnboardingComplete();
      await store.markOnboardingComplete();

      expect(await store.isOnboardingComplete(), isTrue);
      expect(storage.writeCount, 2);
    });

    group('failure handling', () {
      test('a failing read resolves to not complete instead of throwing',
          () async {
        final store = SecureOnboardingStore(
          _FakeSecureStorage(throwOnRead: true),
        );

        expect(await store.isOnboardingComplete(), isFalse);
      });

      test('a failing write is swallowed', () async {
        final store = SecureOnboardingStore(
          _FakeSecureStorage(throwOnWrite: true),
        );

        await expectLater(store.markOnboardingComplete(), completes);
      });

      test('a failing write still leaves a readable store', () async {
        final storage = _FakeSecureStorage(throwOnWrite: true);
        final store = SecureOnboardingStore(storage);

        await store.markOnboardingComplete();

        // Nothing persisted, so onboarding shows again next launch. That is
        // the intended safe fallback, not a silent skip.
        expect(await store.isOnboardingComplete(), isFalse);
      });
    });
  });
}
