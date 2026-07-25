import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/document_viewer/domain/entities/document_view_state.dart';

void main() {
  group('DocumentViewState', () {
    test('should create with default values', () {
      const state = DocumentViewState();
      
      expect(state.currentPage, equals(1));
      expect(state.pageCount, equals(0));
      expect(state.zoomLevel, equals(1.0));
      expect(state.rotation, equals(0.0));
      expect(state.scrollPosition, equals(0.0));
      expect(state.isPasswordProtected, isFalse);
      expect(state.isSearchActive, isFalse);
      expect(state.searchQuery, isEmpty);
    });

    test('copyWith should update specified fields', () {
      const original = DocumentViewState();
      
      final updated = original.copyWith(
        currentPage: 5,
        pageCount: 10,
        zoomLevel: 1.5,
        rotation: 90.0,
      );
      
      expect(updated.currentPage, equals(5));
      expect(updated.pageCount, equals(10));
      expect(updated.zoomLevel, equals(1.5));
      expect(updated.rotation, equals(90.0));
      // Unspecified fields should remain the same
      expect(updated.scrollPosition, equals(0.0));
    });
  });
}
