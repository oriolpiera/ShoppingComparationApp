import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../domain/entities/external_price_observation.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/entities/shopping_list_entry.dart';
import '../../domain/repositories/external_observation_repository.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../domain/repositories/product_item_repository.dart';
import '../../domain/repositories/product_family_repository.dart';
import '../../domain/repositories/supermarket_repository.dart';
import '../../domain/shopping_list_optimizer.dart';

class DriftShoppingListRepository implements ShoppingListRepository {
  final PersistenceDao dao;
  final ProductFamilyRepository productFamilyRepository;
  final SupermarketRepository supermarketRepository;
  final ProductItemRepository productItemRepository;
  final ExternalObservationRepository externalObservationRepository;

  DriftShoppingListRepository(
    this.dao, {
    required this.productFamilyRepository,
    required this.supermarketRepository,
    required this.productItemRepository,
    required this.externalObservationRepository,
  });

  Future<List<ShoppingListEntry>> getShoppingList() async {
    final rows = await dao.getShoppingList();
    return rows
        .map(
          (row) => ShoppingListEntry(
            id: row.id,
            productFamilyId: row.productFamilyId,
            quantity: row.quantity.round(),
          ),
        )
        .toList();
  }

  @override
  Future<List<ShoppingListEntry>> getShoppingNeedEntries() => getShoppingList();

  Future<int> saveShoppingListEntry(ShoppingListEntry entry) {
    return dao.saveShoppingListEntry(
      ShoppingListTableCompanion(
        id: entry.id == null ? const Value.absent() : Value(entry.id!),
        productFamilyId: Value(entry.productFamilyId),
        quantity: Value(entry.quantity),
        productItemId: const Value.absent(),
      ),
    );
  }

  @override
  Future<int> saveShoppingNeedEntry(ShoppingListEntry entry) =>
      saveShoppingListEntry(entry);

  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async {
    final existing = await dao.getShoppingListEntryByFamily(productFamilyId);
    if (existing != null) {
      final updatedId = await saveShoppingListEntry(
        ShoppingListEntry(
          id: existing.id,
          productFamilyId: existing.productFamilyId,
          quantity: existing.quantity.round() + quantity,
        ),
      );
      final check = await dao.getShoppingListEntryByFamily(productFamilyId);
      if (check == null) {
        throw StateError('ShoppingList entry disappeared after update');
      }
      return updatedId;
    }

    final insertedId = await saveShoppingListEntry(
      ShoppingListEntry(productFamilyId: productFamilyId, quantity: quantity),
    );
    final check = await dao.getShoppingListEntryByFamily(productFamilyId);
    if (check == null) {
      throw StateError('ShoppingList entry not found after insert');
    }
    return insertedId;
  }

  @override
  Future<int> addOrIncrementShoppingNeedEntry({
    required int productFamilyId,
    int quantity = 1,
  }) =>
      addOrIncrementShoppingListEntry(
        productFamilyId: productFamilyId,
        quantity: quantity,
      );

  Future<void> deleteShoppingListEntries(List<int> entryIds) {
    return dao.deleteShoppingListEntriesByIds(entryIds);
  }

  @override
  Future<void> deleteShoppingNeedEntries(List<int> entryIds) =>
      deleteShoppingListEntries(entryIds);

  @override
  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries() async {
    final shoppingList = await getShoppingNeedEntries();
    final families = await productFamilyRepository.getProductFamilies(
      onlyActive: false,
    );
    final supermarkets = await supermarketRepository.getSupermarkets(
      onlyActive: true,
    );
    final items = await productItemRepository.getProductItems(
      onlyCurrentPrice: true,
    );

    // Include accepted external observations not yet confirmed locally
    final allObservations =
        await externalObservationRepository.getExternalPriceObservations();
    final storeMappings =
        await externalObservationRepository.getExternalStoreMappings();
    final supermarketIdByExternalStore = {
      for (final m in storeMappings) m.externalStoreId: m.supermarketId,
    };
    final externalItems = <ProductItem>[];
    for (final obs in allObservations) {
      if (obs.reviewStatus !=
              ExternalObservationReviewStatus.acceptedForComparison ||
          obs.localPriceRecordId != null) {
        continue;
      }
      final supermarketId = supermarketIdByExternalStore[obs.externalStoreId];
      if (supermarketId == null) continue;
      final familyId = await productFamilyRepository.findProductFamilyIdByName(
        obs.familyName,
      );
      if (familyId == null) continue;
      externalItems.add(
        ProductItem(
          id: obs.id,
          name: obs.productName,
          isActive: true,
          productFamilyId: familyId,
          supermarketId: supermarketId,
          price: obs.price,
          quantity: obs.quantity,
          unitType: obs.unitType,
          pricePerQuantity: obs.pricePerQuantity,
          dateAdded: obs.observedAt,
          externalObservationId: obs.id,
        ),
      );
    }

    final familyById = {
      for (final family in families)
        if (family.id != null) family.id!: family,
    };

    final supermarketNameById = {
      for (final market in supermarkets)
        if (market.id != null) market.id!: market.name,
    };

    return optimizeShoppingList(
      shoppingList: shoppingList,
      familyById: familyById,
      supermarketNameById: supermarketNameById,
      items: [...items, ...externalItems],
    );
  }
}
