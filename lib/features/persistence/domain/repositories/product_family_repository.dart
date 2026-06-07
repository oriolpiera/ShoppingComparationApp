import '../entities/product_family.dart';

abstract class ProductFamilyRepository {
  Future<List<ProductFamily>> getProductFamilies({bool onlyActive = true});

  Future<int> saveProductFamily(ProductFamily family);

  Future<int> resolveProductFamilyIdByName(String familyName);

  Future<int?> findProductFamilyIdByName(String familyName);

  Future<List<ProductFamily>> getActiveShoppingFamilies();
}
