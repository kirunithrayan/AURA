import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads every real font declared in the built `FontManifest.json` into the
/// test binding, so golden tests render true glyphs (Inter, Source Serif 4,
/// Material Icons) instead of the test fallback box font.
///
/// Deliberately NOT wired into a global `flutter_test_config.dart`: real font
/// metrics differ from the fallback font and would change layout in existing
/// widget tests (for example the onboarding overflow-at-3x-text-scale test).
/// This is invoked only by the golden harness under `test/golden/`, keeping the
/// rest of the suite rendering exactly as before.
///
/// Reuses Flutter's native [FontLoader]; no third-party golden package is
/// required.
Future<void> loadAuraFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final String manifestJson =
      await rootBundle.loadString('FontManifest.json');
  final List<dynamic> manifest = json.decode(manifestJson) as List<dynamic>;

  for (final dynamic entry in manifest) {
    final Map<String, dynamic> family = entry as Map<String, dynamic>;
    final FontLoader loader = FontLoader(family['family'] as String);
    for (final dynamic font in family['fonts'] as List<dynamic>) {
      final Map<String, dynamic> descriptor = font as Map<String, dynamic>;
      loader.addFont(rootBundle.load(descriptor['asset'] as String));
    }
    await loader.load();
  }
}
