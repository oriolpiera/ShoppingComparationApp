import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/normalization/family_unit_normalization.dart';

void main() {
  group('unit normalization', () {
    test('supports unit as a first-class display/storage value', () {
      expect(normalizeUnitTypeForDisplay('unit'), 'unit');
      expect(normalizeUnitTypeForComparison('piece'), 'unit');
      expect(normalizeUnitTypeForStorage('piece'), 'unit');
      expect(normalizeUnitTypeForDisplay('g'), 'g');
      expect(normalizeUnitTypeForDisplay('ml'), 'ml');
    });

    test('canonicalizes family semantics values', () {
      expect(normalizeShoppingUnitForStorage('kg'), 'kilogram');
      expect(normalizeShoppingUnitForStorage('L'), 'liter');
      expect(normalizeShoppingUnitForStorage('unit'), 'piece');
      expect(normalizePurchaseModeForStorage('fresh'), 'weighted');
    });

    test('infers piece semantics for count-based items', () {
      expect(inferShoppingUnitFromUnitType('unit'), 'piece');
      expect(inferPurchaseModeFromUnitType('unit'), 'piece');
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

    test('rejects invalid family/item combinations', () {
      expect(
        validateFamilySemantics(
          shoppingUnit: 'piece',
          purchaseMode: 'weighted',
        ),
        isNotNull,
      );
      expect(
        validateItemSemantics(
          shoppingUnit: 'piece',
          purchaseMode: 'piece',
          packageQuantityAmount: 6,
          packageQuantityUnit: 'unit',
        ),
        isNull,
      );
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
