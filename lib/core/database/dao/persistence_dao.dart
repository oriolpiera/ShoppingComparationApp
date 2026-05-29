import 'package:drift/drift.dart';

import '../drift_database.dart';

class PersistenceDao {
  final AppDriftDatabase db;

  PersistenceDao(this.db);

  Future<List<SupermarketTableData>> getSupermarkets({
    bool onlyActive = true,
  }) {
    final query = db.select(db.supermarketTable)
      ..orderBy([(t) => OrderingTerm.asc(t.nom)]);

    if (onlyActive) {
      query.where((t) => t.actiu.equals(true));
    }

    return query.get();
  }

  Future<int> saveSupermarket(SupermarketTableCompanion companion) {
    return db.into(db.supermarketTable).insertOnConflictUpdate(companion);
  }

  Future<List<ProductFamilyTableData>> getProductFamilies({
    bool onlyActive = true,
  }) {
    final query = db.select(db.productFamilyTable)
      ..orderBy([(t) => OrderingTerm.asc(t.nom)]);

    if (onlyActive) {
      query.where((t) => t.actiu.equals(true));
    }

    return query.get();
  }

  Future<int> saveProductFamily(ProductFamilyTableCompanion companion) {
    return db.into(db.productFamilyTable).insertOnConflictUpdate(companion);
  }

  Future<List<ProductItemTableData>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) {
    final query = db.select(db.productItemTable)
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)]);

    if (productFamilyId != null) {
      query.where((t) => t.productFamilyId.equals(productFamilyId));
    }
    if (supermarketId != null) {
      query.where((t) => t.supermarketId.equals(supermarketId));
    }
    if (onlyCurrentPrice) {
      query.where((t) => t.isCurrentPrice.equals(true));
    }

    return query.get();
  }

  Future<int> saveProductItem(ProductItemTableCompanion companion) {
    return db.into(db.productItemTable).insertOnConflictUpdate(companion);
  }

  Future<List<ProductItemTableData>> getCurrentActiveItemsByBarcode(
      String barcode) {
    final query = db.select(db.productItemTable)
      ..where(
        (t) =>
            t.barcode.equals(barcode) &
            t.isCurrentPrice.equals(true) &
            t.actiu.equals(true),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)]);
    return query.get();
  }

  Future<List<ShoppingListTableData>> getShoppingList() {
    return db.select(db.shoppingListTable).get();
  }

  Future<int> saveShoppingListEntry(ShoppingListTableCompanion companion) {
    return db.into(db.shoppingListTable).insertOnConflictUpdate(companion);
  }

  Future<ShoppingListTableData?> getShoppingListEntryByFamily(int familyId) {
    return (db.select(db.shoppingListTable)
          ..where((t) => t.productFamilyId.equals(familyId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteShoppingListEntriesByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await (db.delete(db.shoppingListTable)..where((t) => t.id.isIn(ids))).go();
  }
}
