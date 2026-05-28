import '../entities/product_family.dart';
import '../entities/product_item.dart';
import '../entities/shopping_list_entry.dart';
import '../../../supermarkets/data/models/supermarket.dart';

abstract class PersistenceRepository {
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true});
  Future<int> saveSupermarket(Supermarket supermarket);

  Future<List<ProductFamily>> getProductFamilies({bool onlyActive = true});
  Future<int> saveProductFamily(ProductFamily family);

  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  });
  Future<int> saveProductItem(ProductItem item);

  Future<List<ShoppingListEntry>> getShoppingList();
  Future<int> saveShoppingListEntry(ShoppingListEntry entry);
}
