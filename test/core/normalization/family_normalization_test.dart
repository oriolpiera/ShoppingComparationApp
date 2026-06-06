import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/normalization/family_normalization.dart';

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
}
