import '../../persistence/domain/entities/product_item.dart';
import '../../supermarkets/data/models/supermarket.dart';

class ProductFamilyComparisonItem {
  const ProductFamilyComparisonItem({
    required this.productItem,
    required this.supermarketName,
    required this.hasInactiveSupermarket,
  });

  final ProductItem productItem;
  final String supermarketName;
  final bool hasInactiveSupermarket;
}

class ProductFamilyComparisonView {
  const ProductFamilyComparisonView({
    required this.items,
    required this.bestUnitPrice,
  });

  final List<ProductFamilyComparisonItem> items;
  final double? bestUnitPrice;
}

ProductFamilyComparisonView buildProductFamilyComparisonView({
  required List<ProductItem> items,
  required Map<int, Supermarket> supermarketById,
}) {
  final comparisonItems =
      items.where((item) => item.isCurrentPrice && item.isActive).map((item) {
    final supermarket = supermarketById[item.supermarketId];
    return ProductFamilyComparisonItem(
      productItem: item,
      supermarketName: supermarket?.name ?? 'Unknown supermarket',
      hasInactiveSupermarket: supermarket == null || !supermarket.isActive,
    );
  }).toList()
        ..sort((a, b) {
          final byUnit = a.productItem.pricePerQuantity
              .compareTo(b.productItem.pricePerQuantity);
          if (byUnit != 0) return byUnit;

          final byPrice = a.productItem.price.compareTo(b.productItem.price);
          if (byPrice != 0) return byPrice;

          return a.supermarketName
              .toLowerCase()
              .compareTo(b.supermarketName.toLowerCase());
        });

  return ProductFamilyComparisonView(
    items: comparisonItems,
    bestUnitPrice: comparisonItems.isEmpty
        ? null
        : comparisonItems.first.productItem.pricePerQuantity,
  );
}
