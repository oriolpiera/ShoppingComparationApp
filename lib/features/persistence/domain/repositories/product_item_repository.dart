import '../entities/product_item.dart';

abstract class ProductItemRepository {
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  });

  Future<int> saveProductItem(ProductItem item);

  Future<int> saveQuickProductItem({
    required String productName,
    required int familyId,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? purchaseMode,
    String? barcode,
  });
}
