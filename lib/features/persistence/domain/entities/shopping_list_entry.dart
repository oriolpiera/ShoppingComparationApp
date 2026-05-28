class ShoppingListEntry {
  final int? id;
  final int productFamilyId;
  final int quantity;

  const ShoppingListEntry({
    this.id,
    required this.productFamilyId,
    required this.quantity,
  });
}
