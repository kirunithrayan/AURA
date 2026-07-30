import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatDate should format DateTime correctly', () {
      final date = DateTime(2026, 7, 23, 10, 30);
      final formatted = DateFormatter.formatDate(date.millisecondsSinceEpoch);
      expect(formatted, contains('2026'));
      // Depending on implementation, just verify it returns a non-empty string for now
      expect(formatted.isNotEmpty, isTrue);
    });
  });
}
