import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/products/domain/validation/product_item_validation.dart';

void main() {
  group('validateItemForFamily', () {
    test('returns null for valid kg/weighted item', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'kilogram',
        purchaseMode: 'weighted',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 2.5,
        unitType: 'kg',
      );

      expect(result, isNull);
    });

    test('returns null for valid unit/piece item', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'piece',
        purchaseMode: 'piece',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 3,
        unitType: 'unit',
      );

      expect(result, isNull);
    });

    test('returns null for valid liter/packaged item', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'liter',
        purchaseMode: 'packaged',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 1,
        unitType: 'L',
      );

      expect(result, isNull);
    });

    test('infers shoppingUnit from unitType when family has none', () {
      const family = ProductFamily(
        name: 'Test',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 1,
        unitType: 'kg',
      );

      expect(result, isNull);
    });

    test('infers purchaseMode from unitType when family has none', () {
      const family = ProductFamily(
        name: 'Test',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 1,
        unitType: 'unit',
      );

      expect(result, isNull);
    });

    test('rejects zero quantity', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'kilogram',
        purchaseMode: 'packaged',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 0,
        unitType: 'kg',
      );

      expect(result, contains('greater than zero'));
    });

    test('rejects negative quantity', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'kilogram',
        purchaseMode: 'packaged',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: -1,
        unitType: 'kg',
      );

      expect(result, contains('greater than zero'));
    });

    test('rejects incompatible shopping unit and unit type', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'piece',
        purchaseMode: 'piece',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 1,
        unitType: 'kg',
      );

      expect(result, contains('incompatible'));
    });

    test('rejects weighted mode with piece shopping unit', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'piece',
        purchaseMode: 'weighted',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 1,
        unitType: 'unit',
      );

      expect(result, contains('incompatible'));
    });

    test('rejects piece mode without piece shopping unit', () {
      const family = ProductFamily(
        name: 'Test',
        shoppingUnit: 'kilogram',
        purchaseMode: 'piece',
      );

      final result = validateItemForFamily(
        family: family,
        quantity: 1,
        unitType: 'kg',
      );

      expect(result, isNotNull);
    });
  });
}
