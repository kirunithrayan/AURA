import 'dart:async';

import '../support/aura_test_fonts.dart';

/// Test configuration scoped to `test/golden/`.
///
/// Flutter's test runner applies the NEAREST `flutter_test_config.dart` to a
/// test file. Because this one lives under `test/golden/`, it affects golden
/// tests only — real fonts are loaded here and nowhere else, so the existing
/// widget tests elsewhere in the tree keep rendering with the fallback font and
/// stay byte-for-byte unchanged.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAuraFonts();
  await testMain();
}
