class ShoppingListEntry {
  final int? id;
  final int productFamilyId;
  final double quantity;
  final int productItemId;

  const ShoppingListEntry({
    this.id,
    required this.productFamilyId,
    required this.quantity,
    required this.productItemId,
  });
}
