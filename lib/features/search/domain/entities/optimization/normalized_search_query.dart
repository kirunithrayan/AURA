import 'package:equatable/equatable.dart';

class NormalizedSearchQuery extends Equatable {

  const NormalizedSearchQuery({
    required this.originalKeyword,
    required this.normalizedKeyword,
    required this.normalizedTokens,
  });
  final String originalKeyword;
  final String normalizedKeyword;
  final List<String> normalizedTokens;

  @override
  List<Object?> get props => [originalKeyword, normalizedKeyword, normalizedTokens];
}
