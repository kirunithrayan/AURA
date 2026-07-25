import 'abstract_tokenizer.dart';

/// Default tokenizer that splits on whitespace boundaries
/// while preserving original token text and character-level positions.
class DefaultTokenizer implements AbstractTokenizer {
  const DefaultTokenizer();

  @override
  List<Token> tokenize(String text) {
    final tokens = <Token>[];
    final pattern = RegExp(r'\S+');

    for (final match in pattern.allMatches(text)) {
      tokens.add(Token(
        text: match.group(0)!,
        position: match.start,
      ));
    }

    return tokens;
  }
}
