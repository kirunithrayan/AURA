import 'dart:io';
import 'package:path/path.dart' as p;
import 'architecture_validator.dart';

class ArchitectureValidatorImpl implements ArchitectureValidator {
  @override
  Future<ValidationResult> validate(String featurePath, List<LayerRule> rules) async {
    final dir = Directory(featurePath);
    if (!dir.existsSync()) {
      throw Exception('Feature path does not exist: $featurePath');
    }

    final violations = <String>[];
    int filesChecked = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        filesChecked++;
        final relativePath = p.relative(entity.path, from: featurePath);
        final content = await entity.readAsString();
        
        // Find which layer this file belongs to based on the relative path
        for (final rule in rules) {
          if (relativePath.startsWith(rule.sourceLayer) || relativePath.contains(p.separator + rule.sourceLayer + p.separator)) {
            _checkImports(entity.path, content, rule, violations);
          }
        }
      }
    }

    return ValidationResult(
      isValid: violations.isEmpty,
      violations: violations,
      filesChecked: filesChecked,
    );
  }

  void _checkImports(String filePath, String content, LayerRule rule, List<String> violations) {
    final lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('import ')) {
        for (final forbidden in rule.forbiddenImports) {
          if (line.contains(forbidden)) {
            violations.add('Violation in $filePath (line ${i + 1}): Imports $forbidden. ${rule.description}');
          }
        }
      }
    }
  }
}
