import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../../../core/normalization/family_normalization.dart';
import '../../../../core/normalization/unit_normalization.dart';
import '../../domain/entities/product_family.dart';
import '../../domain/repositories/product_family_repository.dart';

class DriftProductFamilyRepository implements ProductFamilyRepository {
  final PersistenceDao dao;

  DriftProductFamilyRepository(this.dao);

  @override
  Future<List<ProductFamily>> getProductFamilies({
    bool onlyActive = true,
  }) async {
    final rows = await dao.getProductFamilies(onlyActive: onlyActive);
    return rows
        .map(
          (row) => ProductFamily(
            id: row.id,
            name: row.nom,
            isActive: row.actiu,
            shoppingUnit: row.shoppingUnit,
            purchaseMode: row.purchaseMode,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveProductFamily(ProductFamily family) {
    return dao.saveProductFamily(
      ProductFamilyTableCompanion(
        id: family.id == null ? const Value.absent() : Value(family.id!),
        nom: Value(family.name),
        actiu: Value(family.isActive),
        shoppingUnit: Value(
          family.shoppingUnit == null
              ? null
              : normalizeShoppingUnitForStorage(family.shoppingUnit),
        ),
        purchaseMode: Value(
          family.purchaseMode == null
              ? null
              : normalizePurchaseModeForStorage(family.purchaseMode),
        ),
      ),
    );
  }

  @override
  Future<int> resolveProductFamilyIdByName(String familyName) {
    return resolveOrCreateProductFamily(familyName);
  }

  Future<int> resolveOrCreateProductFamily(
    String familyName, {
    String? shoppingUnit,
    String? purchaseMode,
  }) async {
    final normalizedTarget = normalizeFamilyKey(familyName);
    final families = await getProductFamilies(onlyActive: true);
    for (final family in families) {
      if (family.id != null &&
          normalizeFamilyKey(family.name) == normalizedTarget) {
        final nextShoppingUnit = shoppingUnit == null
            ? family.shoppingUnit
            : normalizeShoppingUnitForStorage(shoppingUnit);
        final nextPurchaseMode = purchaseMode == null
            ? family.purchaseMode
            : normalizePurchaseModeForStorage(purchaseMode);

        if (family.shoppingUnit == null && nextShoppingUnit != null ||
            family.purchaseMode == null && nextPurchaseMode != null) {
          await saveProductFamily(
            ProductFamily(
              id: family.id,
              name: family.name,
              isActive: family.isActive,
              shoppingUnit: family.shoppingUnit ?? nextShoppingUnit,
              purchaseMode: family.purchaseMode ?? nextPurchaseMode,
            ),
          );
        }

        return family.id!;
      }
    }

    return saveProductFamily(
      ProductFamily(
        name: familyName.trim(),
        isActive: true,
        shoppingUnit: shoppingUnit == null
            ? null
            : normalizeShoppingUnitForStorage(shoppingUnit),
        purchaseMode: purchaseMode == null
            ? null
            : normalizePurchaseModeForStorage(purchaseMode),
      ),
    );
  }

  @override
  Future<List<ProductFamily>> getActiveShoppingFamilies() {
    return getProductFamilies(onlyActive: true);
  }
}
