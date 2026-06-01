class ProductFamily {
  final int? id;
  final String name;
  final bool isActive;
  final String? shoppingUnit;
  final String? purchaseMode;

  const ProductFamily({
    this.id,
    required this.name,
    this.isActive = true,
    this.shoppingUnit,
    this.purchaseMode,
  });
}
