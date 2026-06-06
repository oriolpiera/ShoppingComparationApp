import '../../../../core/normalization/family_unit_normalization.dart';
import '../../../persistence/domain/entities/product_family.dart';

String? validateItemForFamily({
  required ProductFamily family,
  required double quantity,
  required String unitType,
}) {
  final shoppingUnit =
      family.shoppingUnit ?? inferShoppingUnitFromUnitType(unitType);
  final purchaseMode =
      family.purchaseMode ?? inferPurchaseModeFromUnitType(unitType);

  return validateItemSemantics(
    shoppingUnit: shoppingUnit,
    purchaseMode: purchaseMode,
    packageQuantityAmount: quantity,
    packageQuantityUnit: unitType,
  );
}
