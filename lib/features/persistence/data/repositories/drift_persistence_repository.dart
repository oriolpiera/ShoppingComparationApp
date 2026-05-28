import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../../supermarkets/data/models/supermarket.dart';
import '../../domain/entities/product_family.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/entities/shopping_list_entry.dart';
import '../../domain/repositories/persistence_repository.dart';

class DriftPersistenceRepository implements PersistenceRepository {
  final PersistenceDao dao;

  DriftPersistenceRepository(this.dao);

  factory DriftPersistenceRepository.fromDatabase(AppDriftDatabase db) {
    return DriftPersistenceRepository(PersistenceDao(db));
  }

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async {
    final rows = await dao.getSupermarkets(onlyActive: onlyActive);
    return rows
        .map(
          (row) => Supermarket(id: row.id, name: row.nom, address: row.adreca),
        )
        .toList();
  }

  @override
  Future<int> saveSupermarket(Supermarket supermarket) {
    return dao.saveSupermarket(
      SupermarketTableCompanion(
        id: supermarket.id == null
            ? const Value.absent()
            : Value(supermarket.id!),
        nom: Value(supermarket.name),
        adreca: Value(supermarket.address),
      ),
    );
  }

  @override
  Future<List<ProductFamily>> getProductFamilies(
      {bool onlyActive = true}) async {
    final rows = await dao.getProductFamilies(onlyActive: onlyActive);
    return rows
        .map((row) =>
            ProductFamily(id: row.id, name: row.nom, isActive: row.actiu))
        .toList();
  }

  @override
  Future<int> saveProductFamily(ProductFamily family) {
    return dao.saveProductFamily(
      ProductFamilyTableCompanion(
        id: family.id == null ? const Value.absent() : Value(family.id!),
        nom: Value(family.name),
        actiu: Value(family.isActive),
      ),
    );
  }

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async {
    final rows = await dao.getProductItems(
      productFamilyId: productFamilyId,
      supermarketId: supermarketId,
      onlyCurrentPrice: onlyCurrentPrice,
    );

    return rows
        .map(
          (row) => ProductItem(
            id: row.id,
            name: row.nom,
            isActive: row.actiu,
            productFamilyId: row.productFamilyId,
            supermarketId: row.supermarketId,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            dateAdded: row.dateAdded,
            isCurrentPrice: row.isCurrentPrice,
            barcode: row.barcode,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveProductItem(ProductItem item) {
    return dao.saveProductItem(
      ProductItemTableCompanion(
        id: item.id == null ? const Value.absent() : Value(item.id!),
        nom: Value(item.name),
        actiu: Value(item.isActive),
        productFamilyId: Value(item.productFamilyId),
        supermarketId: Value(item.supermarketId),
        price: Value(item.price),
        quantity: Value(item.quantity),
        unitType: Value(item.unitType),
        pricePerQuantity: Value(item.pricePerQuantity),
        dateAdded: Value(item.dateAdded),
        isCurrentPrice: Value(item.isCurrentPrice),
        barcode: Value(item.barcode),
      ),
    );
  }

  @override
  Future<List<ShoppingListEntry>> getShoppingList() async {
    final rows = await dao.getShoppingList();
    return rows
        .map(
          (row) => ShoppingListEntry(
            id: row.id,
            productFamilyId: row.productFamilyId,
            quantity: row.quantity,
            productItemId: row.productItemId,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) {
    return dao.saveShoppingListEntry(
      ShoppingListTableCompanion(
        id: entry.id == null ? const Value.absent() : Value(entry.id!),
        productFamilyId: Value(entry.productFamilyId),
        quantity: Value(entry.quantity),
        productItemId: Value(entry.productItemId),
      ),
    );
  }
}
