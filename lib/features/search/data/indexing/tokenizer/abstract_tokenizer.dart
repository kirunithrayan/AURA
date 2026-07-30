/// Represents a token with its position in the source text and original form.
class Token {

  const Token({required this.text, required this.position});
  final String text;
  final int position;
}

/// Contract for splitting raw text into positional tokens.
abstract class AbstractTokenizer {
  List<Token> tokenize(String text);
}
