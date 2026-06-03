class CatalogProduct {
  const CatalogProduct({
    this.id,
    required this.name,
    this.isActive = true,
    required this.productFamilyId,
    this.barcode,
    this.packageQuantityAmount,
    this.packageQuantityUnit,
    this.normalizedMeasurementUnit,
    required this.identityKey,
  });

  final int? id;
  final String name;
  final bool isActive;
  final int productFamilyId;
  final String? barcode;
  final double? packageQuantityAmount;
  final String? packageQuantityUnit;
  final String? normalizedMeasurementUnit;
  final String identityKey;
}
