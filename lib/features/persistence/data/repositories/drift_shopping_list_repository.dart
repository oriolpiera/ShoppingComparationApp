import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../domain/entities/shopping_list_entry.dart';

class DriftShoppingListRepository {
  final PersistenceDao dao;

  DriftShoppingListRepository(this.dao);

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

  Future<void> deleteShoppingListEntries(List<int> entryIds) {
    return dao.deleteShoppingListEntriesByIds(entryIds);
  }
}
