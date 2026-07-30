import 'abstract_token_normalizer.dart';

/// Default normalizer: lowercases, trims whitespace, strips leading/trailing punctuation.
/// Future implementations may add stemming and lemmatization.
class DefaultTokenNormalizer implements AbstractTokenNormalizer {

  const DefaultTokenNormalizer();
  static final _leadingTrailingPunctuation = RegExp(r'^[^\w]+|[^\w]+$');

  @override
  String normalize(String token) => token
        .toLowerCase()
        .trim()
        .replaceAll(_leadingTrailingPunctuation, '');
}
