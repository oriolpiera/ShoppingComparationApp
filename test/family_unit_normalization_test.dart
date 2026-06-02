import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/normalization/family_unit_normalization.dart';

void main() {
  group('normalizeFamilySearchText', () {
    test('removes diacritics and normalizes spaces', () {
      expect(
        normalizeFamilySearchText('  LèT  Ñata  '),
        'let nata',
      );
    });
  });

  group('normalizeFamilyKey', () {
    test('keeps behavior for punctuation and spacing', () {
      expect(
        normalizeFamilyKey('  Café---Molido (250g)  '),
        'cafe molido 250g',
      );
    });

    test('matches equivalent names with accents', () {
      expect(normalizeFamilyKey('Lácteos'), normalizeFamilyKey('Lacteos'));
    });
  });

  group('unit type rules', () {
    test('display keeps canonical unit labels', () {
      expect(normalizeUnitTypeForDisplay(' l '), 'L');
      expect(normalizeUnitTypeForDisplay('kg'), 'kg');
      expect(normalizeUnitTypeForDisplay('ml'), 'ml');
      expect(normalizeUnitTypeForDisplay('unit'), 'unit');
    });

    test('comparison canonicalizes known aliases', () {
      expect(normalizeUnitTypeForComparison(' L '), 'l');
      expect(normalizeUnitTypeForComparison('Kg'), 'kg');
      expect(normalizeUnitTypeForComparison('piece'), 'unit');
    });

    test('storage uses canonical persisted values', () {
      expect(normalizeUnitTypeForStorage(' L '), 'L');
      expect(normalizeUnitTypeForStorage(' kg '), 'kg');
      expect(normalizeUnitTypeForStorage('piece'), 'unit');
    });
  });
}
