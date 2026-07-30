enum ReadingTheme { system, light, dark, sepia }

class ReadingPreferences {

  const ReadingPreferences({
    this.fontSize = 16.0,
    this.lineSpacing = 1.5,
    this.readingTheme = ReadingTheme.system,
  });
  final double fontSize;
  final double lineSpacing;
  final ReadingTheme readingTheme;

  ReadingPreferences copyWith({
    double? fontSize,
    double? lineSpacing,
    ReadingTheme? readingTheme,
  }) => ReadingPreferences(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      readingTheme: readingTheme ?? this.readingTheme,
    );
}
