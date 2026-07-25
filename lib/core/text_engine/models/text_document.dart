class TextDocument {
  final String title;
  final String content;
  final List<String> headings;
  final int paragraphCount;
  final int wordCount;
  final int characterCount;
  final String sourceType;
  
  // Optional Metadata
  final String? detectedLanguage;
  final String? encoding;
  final int? estimatedReadingTime;
  final String? parserVersion;

  const TextDocument({
    required this.title,
    required this.content,
    required this.headings,
    required this.paragraphCount,
    required this.wordCount,
    required this.characterCount,
    required this.sourceType,
    this.detectedLanguage,
    this.encoding,
    this.estimatedReadingTime,
    this.parserVersion,
  });
}
