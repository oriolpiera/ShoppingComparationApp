import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/entities/supermarket.dart';

class ProductFamilyDetailsData {
  const ProductFamilyDetailsData(
    this.items,
    this.supermarketById,
    this.activeItemCount,
  );

  final List<ProductItem> items;
  final Map<int, Supermarket> supermarketById;
  final int activeItemCount;
}
