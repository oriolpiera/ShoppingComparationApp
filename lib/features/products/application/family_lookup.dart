import '../../../core/normalization/family_unit_normalization.dart';
import '../../persistence/domain/entities/product_family.dart';

ProductFamily? findExistingFamilyByName({
  required Iterable<ProductFamily> families,
  required String familyName,
}) {
  final normalizedTarget = normalizeFamilyKey(familyName);

  for (final family in families) {
    if (normalizeFamilyKey(family.name) == normalizedTarget) {
      return family;
    }
  }

  return null;
}
