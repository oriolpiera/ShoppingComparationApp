String normalizeFamilySearchText(String value) {
  final lower = value.toLowerCase().trim();
  final buffer = StringBuffer();

  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_diacriticsMap[char] ?? char);
  }

  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String normalizeFamilyKey(String value) {
  return normalizeFamilySearchText(value)
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Returns the canonical display label for a unit type.
/// Only canonical units are exposed in the UI: `kg`, `L`, and `unit`.
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

bool isLiterUnit(String unitType) {
  return normalizeUnitTypeForComparison(unitType) == 'l';
}

const _diacriticsMap = <String, String>{
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};
