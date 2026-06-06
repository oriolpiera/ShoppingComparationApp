import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/products/application/family_lookup.dart';

void main() {
  group('findExistingFamilyByName', () {
    final families = [
      const ProductFamily(id: 1, name: 'Lácteos'),
      const ProductFamily(id: 2, name: 'Carnes'),
      const ProductFamily(id: 3, name: 'Frutas y Verduras'),
    ];

    test('finds family by exact name', () {
      final result = findExistingFamilyByName(
        families: families,
        familyName: 'Carnes',
      );

      expect(result, isNotNull);
      expect(result!.id, 2);
    });

    test('finds family with diacritics normalization', () {
      final result = findExistingFamilyByName(
        families: families,
        familyName: 'lacteos',
      );

      expect(result, isNotNull);
      expect(result!.id, 1);
    });

    test('finds family with extra whitespace', () {
      final result = findExistingFamilyByName(
        families: families,
        familyName: '  Frutas y Verduras  ',
      );

      expect(result, isNotNull);
      expect(result!.id, 3);
    });

    test('returns null for non-existent family', () {
      final result = findExistingFamilyByName(
        families: families,
        familyName: 'Bebidas',
      );

      expect(result, isNull);
    });

    test('returns null for empty families', () {
      final result = findExistingFamilyByName(
        families: [],
        familyName: 'Carnes',
      );

      expect(result, isNull);
    });

    test('returns first match when multiple families normalize to same key',
        () {
      final duplicates = [
        const ProductFamily(id: 1, name: 'Café'),
        const ProductFamily(id: 2, name: 'Cafe'),
      ];

      final result = findExistingFamilyByName(
        families: duplicates,
        familyName: 'cafe',
      );

      expect(result, isNotNull);
      expect(result!.id, 1);
    });

    test('finds family despite punctuation in name', () {
      final familiesWithPunctuation = [
        const ProductFamily(id: 1, name: "It's Fresh!"),
      ];

      final result = findExistingFamilyByName(
        families: familiesWithPunctuation,
        familyName: "it's fresh!",
      );

      expect(result, isNotNull);
      expect(result!.id, 1);
    });
  });
}
