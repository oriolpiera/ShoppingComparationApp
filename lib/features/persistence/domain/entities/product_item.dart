class ProductItem {
  final int? id;
  final String name;
  final bool isActive;
  final int productFamilyId;
  final int supermarketId;
  final double price;
  final double quantity;
  final String unitType;
  final double pricePerQuantity;
  final DateTime dateAdded;
  final bool isCurrentPrice;
  final String? barcode;
  final double? packageQuantityAmount;
  final String? packageQuantityUnit;
  final String? normalizedMeasurementUnit;
  final int? externalObservationId;

  const ProductItem({
    this.id,
    required this.name,
    this.isActive = true,
    required this.productFamilyId,
    required this.supermarketId,
    required this.price,
    required this.quantity,
    required this.unitType,
    required this.pricePerQuantity,
    required this.dateAdded,
    this.isCurrentPrice = true,
    this.barcode,
    this.packageQuantityAmount,
    this.packageQuantityUnit,
    this.normalizedMeasurementUnit,
    this.externalObservationId,
  });

  bool get isOpenPricesSource => externalObservationId != null;
}
