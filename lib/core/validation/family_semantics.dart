import '../normalization/unit_normalization.dart';

bool areShoppingUnitAndUnitTypeCompatible({
  required String shoppingUnit,
  required String unitType,
}) {
  final canonicalShoppingUnit = normalizeShoppingUnitForStorage(shoppingUnit);
  final canonicalUnitType = normalizeUnitTypeForComparison(unitType);

  return switch (canonicalShoppingUnit) {
    'kilogram' => canonicalUnitType == 'kg' || canonicalUnitType == 'g',
    'liter' => canonicalUnitType == 'l' || canonicalUnitType == 'ml',
    'piece' => canonicalUnitType == 'unit',
    _ => false,
  };
}

String? validateFamilySemantics({
  required String shoppingUnit,
  required String purchaseMode,
}) {
  final canonicalShoppingUnit = normalizeShoppingUnitForStorage(shoppingUnit);
  final canonicalPurchaseMode = normalizePurchaseModeForStorage(purchaseMode);

  if (canonicalPurchaseMode == 'weighted' && canonicalShoppingUnit == 'piece') {
    return 'Weighted mode is incompatible with piece shopping unit.';
  }

  if (canonicalPurchaseMode == 'piece' && canonicalShoppingUnit != 'piece') {
    return 'Piece mode requires piece shopping unit.';
  }

  return null;
}

String? validateItemSemantics({
  required String shoppingUnit,
  required String purchaseMode,
  required double packageQuantityAmount,
  required String packageQuantityUnit,
}) {
  final familyError = validateFamilySemantics(
    shoppingUnit: shoppingUnit,
    purchaseMode: purchaseMode,
  );
  if (familyError != null) return familyError;

  if (packageQuantityAmount <= 0) {
    return 'Package quantity must be greater than zero.';
  }

  if (!areShoppingUnitAndUnitTypeCompatible(
    shoppingUnit: shoppingUnit,
    unitType: packageQuantityUnit,
  )) {
    return 'Shopping unit and package measurement unit are incompatible.';
  }

  return null;
}
