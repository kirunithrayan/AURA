class ValidationResult {

  const ValidationResult({
    required this.isValid,
    required this.violations,
    required this.filesChecked,
  });
  final bool isValid;
  final List<String> violations;
  final int filesChecked;
}

class LayerRule {

  const LayerRule({
    required this.sourceLayer,
    required this.forbiddenImports,
    required this.description,
  });
  final String sourceLayer;
  final List<String> forbiddenImports;
  final String description;
}

abstract class ArchitectureValidator {
  /// Validates the provided rules against a given feature directory.
  Future<ValidationResult> validate(String featurePath, List<LayerRule> rules);
}
