import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../../supermarkets/data/models/supermarket.dart';
import '../../domain/entities/optimized_shopping.dart';
import '../../domain/entities/product_family.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/entities/shopping_list_entry.dart';
import '../../domain/repositories/persistence_repository.dart';

class DriftPersistenceRepository implements PersistenceRepository {
  final PersistenceDao dao;

  static final _diacriticsMap = <String, String>{
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  DriftPersistenceRepository(this.dao);

  factory DriftPersistenceRepository.fromDatabase(AppDriftDatabase db) {
    return DriftPersistenceRepository(PersistenceDao(db));
  }

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async {
    final rows = await dao.getSupermarkets(onlyActive: onlyActive);
    return rows
        .map(
          (row) => Supermarket(
            id: row.id,
            name: row.nom,
            address: row.adreca,
            isActive: row.actiu,
          ),
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
        actiu: Value(supermarket.isActive),
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
  Future<int> resolveProductFamilyIdByName(String familyName) async {
    final normalizedTarget = _normalizeKey(familyName);
    final families = await getProductFamilies(onlyActive: true);
    for (final family in families) {
      if (family.id != null && _normalizeKey(family.name) == normalizedTarget) {
        return family.id!;
      }
    }

    return saveProductFamily(
        ProductFamily(name: familyName.trim(), isActive: true));
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
  Future<int?> getLastUsedSupermarketId() async {
    final rows = await dao.getProductItems(onlyCurrentPrice: false);
    if (rows.isEmpty) return null;
    return rows.first.supermarketId;
  }

  @override
  Future<int> saveQuickProductItem({
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? barcode,
  }) async {
    final trimmedName = productName.trim();
    final familyId = await resolveProductFamilyIdByName(familyName);

    final currentRows = await dao.getProductItems(
      productFamilyId: familyId,
      supermarketId: supermarketId,
      onlyCurrentPrice: true,
    );

    final normalizedProduct = _normalizeKey(trimmedName);
    for (final row in currentRows) {
      if (_normalizeKey(row.nom) == normalizedProduct) {
        await dao.saveProductItem(
          ProductItemTableCompanion(
            id: Value(row.id),
            nom: Value(row.nom),
            actiu: Value(row.actiu),
            productFamilyId: Value(row.productFamilyId),
            supermarketId: Value(row.supermarketId),
            price: Value(row.price),
            quantity: Value(row.quantity),
            unitType: Value(row.unitType),
            pricePerQuantity: Value(row.pricePerQuantity),
            dateAdded: Value(row.dateAdded),
            isCurrentPrice: const Value(false),
            barcode: Value(row.barcode),
          ),
        );
      }
    }

    return saveProductItem(
      ProductItem(
        name: trimmedName,
        isActive: true,
        productFamilyId: familyId,
        supermarketId: supermarketId,
        price: price,
        quantity: quantity,
        unitType: unitType.trim(),
        pricePerQuantity: quantity == 0 ? 0 : price / quantity,
        dateAdded: DateTime.now(),
        isCurrentPrice: true,
        barcode: barcode,
      ),
    );
  }

  String _normalizeKey(String value) {
    final lower = value.toLowerCase().trim();
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacriticsMap[char] ?? char);
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async {
    final shoppingList = await getShoppingList();
    final families = await getProductFamilies(onlyActive: true);
    final supermarkets = await getSupermarkets(onlyActive: true);
    final items = await getProductItems(onlyCurrentPrice: true);

    final familyNameById = {
      for (final family in families)
        if (family.id != null) family.id!: family.name,
    };
    final supermarketNameById = {
      for (final market in supermarkets)
        if (market.id != null) market.id!: market.name,
    };

    final cheapestByFamily = <int, ProductItem>{};
    for (final item
        in items.where((item) => item.isActive && item.isCurrentPrice)) {
      final current = cheapestByFamily[item.productFamilyId];
      if (current == null || item.pricePerQuantity < current.pricePerQuantity) {
        cheapestByFamily[item.productFamilyId] = item;
      }
    }

    final groups = <int, List<OptimizedShoppingItem>>{};

    for (final entry in shoppingList) {
      final bestItem = cheapestByFamily[entry.productFamilyId];
      if (bestItem == null) {
        continue;
      }

      final marketId = bestItem.supermarketId;
      final marketName = supermarketNameById[marketId];
      final familyName = familyNameById[entry.productFamilyId];
      if (marketName == null || familyName == null) {
        continue;
      }

      groups.putIfAbsent(marketId, () => []).add(
            OptimizedShoppingItem(
              shoppingListEntryId: entry.id ?? -1,
              productFamilyId: entry.productFamilyId,
              productFamilyName: familyName,
              quantity: entry.quantity,
              sourceProductItemId: entry.productItemId,
              bestItem: bestItem,
            ),
          );
    }

    final result = groups.entries
        .map(
          (entry) => OptimizedShoppingGroup(
            supermarketId: entry.key,
            supermarketName: supermarketNameById[entry.key]!,
            items: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.supermarketName.compareTo(b.supermarketName));

    return result;
  }
}
