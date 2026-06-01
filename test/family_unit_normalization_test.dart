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
    test('display uses L for liter and kg otherwise', () {
      expect(normalizeUnitTypeForDisplay(' l '), 'L');
      expect(normalizeUnitTypeForDisplay('kg'), 'kg');
      expect(normalizeUnitTypeForDisplay('ml'), 'kg');
    });

    test('comparison is trim + lowercase', () {
      expect(normalizeUnitTypeForComparison(' L '), 'l');
      expect(normalizeUnitTypeForComparison('Kg'), 'kg');
    });

    test('storage trims only', () {
      expect(normalizeUnitTypeForStorage(' L '), 'L');
      expect(normalizeUnitTypeForStorage(' kg '), 'kg');
    });
  });
}
