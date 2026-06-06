String normalizeUnitTypeForDisplay(String unitType) {
  switch (normalizeUnitTypeForComparison(unitType)) {
    case 'g':
      return 'g';
    case 'l':
      return 'L';
    case 'ml':
      return 'ml';
    case 'unit':
      return 'unit';
    default:
      return 'kg';
  }
}

String normalizeUnitTypeForComparison(String unitType) {
  switch (unitType.trim().toLowerCase()) {
    case 'g':
    case 'gram':
      return 'g';
    case 'kg':
    case 'kilogram':
      return 'kg';
    case 'ml':
    case 'milliliter':
      return 'ml';
    case 'l':
    case 'liter':
      return 'l';
    case 'unit':
    case 'piece':
      return 'unit';
    default:
      return unitType.trim().toLowerCase();
  }
}

String normalizeUnitTypeForStorage(String unitType) {
  switch (normalizeUnitTypeForComparison(unitType)) {
    case 'g':
      return 'g';
    case 'l':
      return 'L';
    case 'ml':
      return 'ml';
    case 'unit':
      return 'unit';
    case 'kg':
      return 'kg';
    default:
      return unitType.trim();
  }
}

String normalizeShoppingUnitForStorage(
  String? shoppingUnit, {
  String fallback = 'kilogram',
}) {
  switch (shoppingUnit?.trim().toLowerCase()) {
    case 'kg':
    case 'kilogram':
      return 'kilogram';
    case 'l':
    case 'liter':
      return 'liter';
    case 'piece':
    case 'unit':
      return 'piece';
    default:
      return fallback;
  }
}

String normalizePurchaseModeForStorage(
  String? purchaseMode, {
  String fallback = 'packaged',
}) {
  switch (purchaseMode?.trim().toLowerCase()) {
    case 'fresh':
    case 'weighted':
      return 'weighted';
    case 'piece':
      return 'piece';
    case 'packaged':
      return 'packaged';
    default:
      return fallback;
  }
}

String inferShoppingUnitFromUnitType(String unitType) {
  switch (normalizeUnitTypeForComparison(unitType)) {
    case 'l':
      return 'liter';
    case 'unit':
      return 'piece';
    default:
      return 'kilogram';
  }
}

String inferPurchaseModeFromUnitType(String unitType) {
  return normalizeUnitTypeForComparison(unitType) == 'unit'
      ? 'piece'
      : 'packaged';
}

bool isLiterUnit(String unitType) {
  return normalizeUnitTypeForComparison(unitType) == 'l';
}
