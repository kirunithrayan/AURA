import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/reading_preferences.dart';

class ReadingPreferencesLocalDataSource {
  final FlutterSecureStorage _storage;
  
  static const _keyFontSize = 'pref_font_size';
  static const _keyLineSpacing = 'pref_line_spacing';
  static const _keyReadingTheme = 'pref_reading_theme';

  ReadingPreferencesLocalDataSource(this._storage);

  Future<ReadingPreferences> getPreferences() async {
    final fontSizeStr = await _storage.read(key: _keyFontSize);
    final lineSpacingStr = await _storage.read(key: _keyLineSpacing);
    final themeStr = await _storage.read(key: _keyReadingTheme);

    final fontSize = fontSizeStr != null ? double.tryParse(fontSizeStr) ?? 16.0 : 16.0;
    final lineSpacing = lineSpacingStr != null ? double.tryParse(lineSpacingStr) ?? 1.5 : 1.5;
    
    ReadingTheme theme = ReadingTheme.system;
    if (themeStr != null) {
      theme = ReadingTheme.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ReadingTheme.system,
      );
    }

    return ReadingPreferences(
      fontSize: fontSize,
      lineSpacing: lineSpacing,
      readingTheme: theme,
    );
  }

  Future<void> savePreferences(ReadingPreferences prefs) async {
    await _storage.write(key: _keyFontSize, value: prefs.fontSize.toString());
    await _storage.write(key: _keyLineSpacing, value: prefs.lineSpacing.toString());
    await _storage.write(key: _keyReadingTheme, value: prefs.readingTheme.toString());
  }
}
