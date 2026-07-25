import 'package:equatable/equatable.dart';

class NormalizedSearchQuery extends Equatable {
  final String originalKeyword;
  final String normalizedKeyword;
  final List<String> normalizedTokens;

  const NormalizedSearchQuery({
    required this.originalKeyword,
    required this.normalizedKeyword,
    required this.normalizedTokens,
  });

  @override
  List<Object?> get props => [originalKeyword, normalizedKeyword, normalizedTokens];
}
