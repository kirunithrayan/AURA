import 'package:aura/core/database/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for the physical-device "Failed to create workspace"
/// bug (Realme 12 Pro 5G).
///
/// Root cause: `FlutterSecureStorage.read` threw
/// `BadPaddingException: BAD_DECRYPT` — the Keystore-wrapped database key could
/// no longer be decrypted. The exception propagated out of `DatabaseHelper` and
/// aborted every database operation, surfacing only as a generic snackbar.
///
/// `resolveDatabaseKey` must recover from a genuinely-undecryptable entry, but
/// must NOT swallow unrelated failures (which would risk regenerating the key —
/// and, downstream, deleting the database — for a transient/unexpected error).
bool _isBadDecrypt(Object e) {
  final String m = e.toString().toLowerCase();
  return m.contains('bad_decrypt') || m.contains('badpadding');
}

void main() {
  group('DatabaseHelper.resolveDatabaseKey', () {
    test('returns the stored key untouched when read succeeds', () async {
      var writes = 0;
      final result = await DatabaseHelper.resolveDatabaseKey(
        read: () async => 'stored-key',
        write: (_) async => writes++,
        deleteKey: () async {},
        generate: () => 'new-key',
        isUnrecoverable: _isBadDecrypt,
      );

      expect(result.key, 'stored-key');
      expect(result.freshlyGenerated, isFalse,
          reason: 'a healthy stored key must be preserved, not regenerated');
      expect(writes, 0);
    });

    test('generates and persists a key when none is stored yet', () async {
      String? written;
      final result = await DatabaseHelper.resolveDatabaseKey(
        read: () async => null,
        write: (v) async => written = v,
        deleteKey: () async {},
        generate: () => 'fresh-key',
        isUnrecoverable: _isBadDecrypt,
      );

      expect(result.key, 'fresh-key');
      expect(result.freshlyGenerated, isTrue);
      expect(written, 'fresh-key', reason: 'a new key must be persisted');
    });

    test(
        'recovers when read throws BadPaddingException/BAD_DECRYPT '
        '(the exact device failure)', () async {
      var deleted = false;
      String? written;

      final result = await DatabaseHelper.resolveDatabaseKey(
        read: () async => throw Exception(
          'PlatformException(Exception encountered, read, '
          'javax.crypto.BadPaddingException: BAD_DECRYPT)',
        ),
        write: (v) async => written = v,
        deleteKey: () async => deleted = true,
        generate: () => 'recovered-key',
        isUnrecoverable: _isBadDecrypt,
      );

      expect(result.key, 'recovered-key');
      expect(result.freshlyGenerated, isTrue,
          reason: 'only a freshly generated key may authorise DB recreation');
      expect(deleted, isTrue, reason: 'the corrupt entry must be dropped');
      expect(written, 'recovered-key');
    });

    test('surfaces (rethrows) an UNRELATED read failure — never regenerates',
        () async {
      var writes = 0;
      var deletes = 0;

      await expectLater(
        DatabaseHelper.resolveDatabaseKey(
          read: () async =>
              throw Exception('MissingPluginException / platform I/O error'),
          write: (_) async => writes++,
          deleteKey: () async => deletes++,
          generate: () => 'must-not-be-used',
          isUnrecoverable: _isBadDecrypt,
        ),
        throwsA(isA<Exception>()),
      );

      expect(writes, 0, reason: 'an unexpected failure must not mint a new key');
      expect(deletes, 0, reason: 'an unexpected failure must not drop the key');
    });

    test('still recovers when deleting the corrupt entry also fails', () async {
      String? written;
      final result = await DatabaseHelper.resolveDatabaseKey(
        read: () async => throw Exception('BAD_DECRYPT'),
        write: (v) async => written = v,
        deleteKey: () async => throw Exception('delete failed too'),
        generate: () => 'recovered-key',
        isUnrecoverable: _isBadDecrypt,
      );

      expect(result.key, 'recovered-key');
      expect(result.freshlyGenerated, isTrue);
      expect(written, 'recovered-key');
    });
  });
}
