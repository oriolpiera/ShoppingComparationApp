import 'family_unit_normalization.dart';

String buildCatalogProductIdentityKey({
  required int productFamilyId,
  required String name,
  required double quantity,
  required String unitType,
  required String? barcode,
}) {
  final normalizedBarcode = barcode?.trim() ?? '';
  if (normalizedBarcode.isNotEmpty) {
    return 'barcode:$normalizedBarcode';
  }

  return 'fallback:$productFamilyId|${normalizeFamilyKey(name)}|${quantity.toStringAsFixed(6)}|${normalizeUnitTypeForStorage(unitType)}';
}
