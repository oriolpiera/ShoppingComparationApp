import '../shopping_list_optimizer.dart';

abstract class ShoppingNeedOptimizer {
  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries();
}
