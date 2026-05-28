import 'product_item.dart';

class OptimizedShoppingItem {
  final int shoppingListEntryId;
  final int productFamilyId;
  final String productFamilyName;
  final int quantity;
  final ProductItem bestItem;

  const OptimizedShoppingItem({
    required this.shoppingListEntryId,
    required this.productFamilyId,
    required this.productFamilyName,
    required this.quantity,
    required this.bestItem,
  });

  double get estimatedCost => quantity * bestItem.pricePerQuantity;
}

class OptimizedShoppingGroup {
  final int supermarketId;
  final String supermarketName;
  final List<OptimizedShoppingItem> items;

  const OptimizedShoppingGroup({
    required this.supermarketId,
    required this.supermarketName,
    required this.items,
  });

  double get totalEstimatedCost =>
      items.fold(0, (sum, item) => sum + item.estimatedCost);
}
