import 'catalog_product.dart';
import 'price_record.dart';
import 'product_item.dart';

class BarcodeMatchResult {
  const BarcodeMatchResult({
    required this.catalogProduct,
    required this.priceRecord,
    required this.familyName,
    required this.supermarketName,
  });

  final CatalogProduct catalogProduct;
  final PriceRecord priceRecord;
  final String familyName;
  final String supermarketName;

  double get quantity => catalogProduct.packageQuantityAmount ?? 0;

  String get unitType =>
      catalogProduct.packageQuantityUnit ??
      catalogProduct.normalizedMeasurementUnit ??
      'kg';

  double get pricePerQuantity =>
      quantity == 0 ? 0 : priceRecord.price / quantity;

  /// Compatibility read model for legacy UI code.
  ///
  /// This getter assumes the backing query already filtered to the latest
  /// active supermarket price for the catalog product, so `isCurrentPrice`
  /// is intentionally hardcoded to `true` here.
  ProductItem get productItem => ProductItem(
        id: priceRecord.id,
        name: catalogProduct.name,
        isActive: catalogProduct.isActive && priceRecord.isActive,
        productFamilyId: catalogProduct.productFamilyId,
        supermarketId: priceRecord.supermarketId,
        price: priceRecord.price,
        quantity: quantity,
        unitType: unitType,
        pricePerQuantity: pricePerQuantity,
        dateAdded: priceRecord.observedAt,
        isCurrentPrice: true,
        barcode: catalogProduct.barcode,
        packageQuantityAmount: catalogProduct.packageQuantityAmount,
        packageQuantityUnit: catalogProduct.packageQuantityUnit,
        normalizedMeasurementUnit: catalogProduct.normalizedMeasurementUnit,
        externalObservationId: priceRecord.externalObservationId,
      );
}
