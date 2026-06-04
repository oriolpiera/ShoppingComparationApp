import '../entities/product_family.dart';
import '../entities/shopping_list_entry.dart';
import '../shopping_list_optimizer.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingListEntry>> getShoppingNeedEntries();

  Future<int> saveShoppingNeedEntry(ShoppingListEntry entry);

  Future<int> addOrIncrementShoppingNeedEntry({
    required int productFamilyId,
    int quantity = 1,
  });

  Future<void> deleteShoppingNeedEntries(List<int> entryIds);

  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries();

  Future<List<ProductFamily>> getActiveShoppingFamilies();
}
