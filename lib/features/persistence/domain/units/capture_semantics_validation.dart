import 'measurement.dart';

MeasurementUnit? measurementUnitFromCode(String unitCode) {
  switch (unitCode) {
    case 'kg':
      return MeasurementUnit.kilogram;
    case 'L':
      return MeasurementUnit.liter;
    case 'unit':
      return MeasurementUnit.unit;
    default:
      return null;
  }
}

MeasurementUnit? measurementUnitFromShoppingUnit(String shoppingUnit) {
  switch (shoppingUnit) {
    case 'kilogram':
      return MeasurementUnit.kilogram;
    case 'liter':
      return MeasurementUnit.liter;
    case 'piece':
      return MeasurementUnit.unit;
    default:
      return null;
  }
}

String? validateFamilySemantics({
  required String shoppingUnit,
  required String purchaseMode,
}) {
  final unit = measurementUnitFromShoppingUnit(shoppingUnit);
  if (unit == null) return 'Invalid shopping unit.';

  if (purchaseMode == 'piece' && unit.dimension != MeasurementDimension.count) {
    return 'Piece mode requires piece shopping unit.';
  }
  if (purchaseMode == 'weighted' && unit.dimension == MeasurementDimension.count) {
    return 'Weighted mode is incompatible with piece shopping unit.';
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

  final familyUnit = measurementUnitFromShoppingUnit(shoppingUnit)!;
  final itemUnit = measurementUnitFromCode(packageQuantityUnit);
  if (itemUnit == null) return 'Invalid package measurement unit.';

  if (!familyUnit.isCompatibleWith(itemUnit)) {
    return 'Shopping unit and package measurement unit are incompatible.';
  }

  if (purchaseMode == 'piece' && packageQuantityAmount != 1) {
    return 'Piece mode requires package quantity 1.';
  }

  return null;
}
