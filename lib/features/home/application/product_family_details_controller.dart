import '../../../core/normalization/family_unit_normalization.dart';
import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/repositories/persistence_repository.dart';
import 'product_family_details_data.dart';

class ProductFamilyDetailsController {
  ProductFamilyDetailsController({
    required PersistenceRepository repository,
    required ProductFamily family,
  })  : _repository = repository,
        _family = family;

  final PersistenceRepository _repository;
  final ProductFamily _family;

  Future<ProductFamilyDetailsData> loadData() async {
    final familyId = _family.id;
    if (familyId == null) {
      return const ProductFamilyDetailsData([], {}, 0);
    }

    final items = await _repository.getProductItems(
      productFamilyId: familyId,
      onlyCurrentPrice: false,
    );
    final supermarkets = await _repository.getSupermarkets(
      onlyActive: false,
    );
    final supermarketById = {
      for (final supermarket in supermarkets)
        if (supermarket.id != null) supermarket.id!: supermarket,
    };

    final activeItemCount = items.where((item) => item.isActive).length;
    return ProductFamilyDetailsData(items, supermarketById, activeItemCount);
  }

  Future<String?> saveEditedItem({
    required ProductItem original,
    required String name,
    required double price,
    required double quantity,
    required String unitType,
  }) async {
    final shoppingUnit =
        _family.shoppingUnit ?? inferShoppingUnitFromUnitType(unitType);
    final purchaseMode =
        _family.purchaseMode ?? inferPurchaseModeFromUnitType(unitType);
    final familyError = validateItemSemantics(
      shoppingUnit: shoppingUnit,
      purchaseMode: purchaseMode,
      packageQuantityAmount: quantity,
      packageQuantityUnit: unitType,
    );
    if (familyError != null) return familyError;

    final storedUnitType = normalizeUnitTypeForStorage(unitType);
    await _repository.saveProductItem(
      ProductItem(
        id: original.id,
        name: name,
        isActive: original.isActive,
        productFamilyId: original.productFamilyId,
        supermarketId: original.supermarketId,
        price: price,
        quantity: quantity,
        unitType: storedUnitType,
        pricePerQuantity: price / quantity,
        packageQuantityAmount: quantity,
        packageQuantityUnit: storedUnitType,
        normalizedMeasurementUnit:
            normalizeUnitTypeForComparison(storedUnitType),
        dateAdded: original.dateAdded,
        isCurrentPrice: original.isCurrentPrice,
        barcode: original.barcode,
      ),
    );
    return null;
  }

  Future<void> inactivateItem(ProductItem item) async {
    await _repository.saveProductItem(
      ProductItem(
        id: item.id,
        name: item.name,
        isActive: false,
        productFamilyId: item.productFamilyId,
        supermarketId: item.supermarketId,
        price: item.price,
        quantity: item.quantity,
        unitType: item.unitType,
        pricePerQuantity: item.pricePerQuantity,
        dateAdded: item.dateAdded,
        isCurrentPrice: item.isCurrentPrice,
        barcode: item.barcode,
        packageQuantityAmount: item.packageQuantityAmount,
        packageQuantityUnit: item.packageQuantityUnit,
        normalizedMeasurementUnit: item.normalizedMeasurementUnit,
        externalObservationId: item.externalObservationId,
      ),
    );
  }

  ProductFamily get family => _family;
}
