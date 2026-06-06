import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/validation/family_semantics.dart';

void main() {
  group('compatibility checks', () {
    test('areShoppingUnitAndUnitTypeCompatible', () {
      expect(
        areShoppingUnitAndUnitTypeCompatible(
          shoppingUnit: 'piece',
          unitType: 'unit',
        ),
        isTrue,
      );
      expect(
        areShoppingUnitAndUnitTypeCompatible(
          shoppingUnit: 'kilogram',
          unitType: 'g',
        ),
        isTrue,
      );
    });

    test('rejects invalid family combinations', () {
      expect(
        validateFamilySemantics(
          shoppingUnit: 'piece',
          purchaseMode: 'weighted',
        ),
        isNotNull,
      );
    });

    test('accepts valid item semantics', () {
      expect(
        validateItemSemantics(
          shoppingUnit: 'piece',
          purchaseMode: 'piece',
          packageQuantityAmount: 6,
          packageQuantityUnit: 'unit',
        ),
        isNull,
      );
    });

    test('rejects invalid item semantics', () {
      expect(
        validateItemSemantics(
          shoppingUnit: 'liter',
          purchaseMode: 'packaged',
          packageQuantityAmount: 6,
          packageQuantityUnit: 'unit',
        ),
        isNotNull,
      );
    });
  });
}
