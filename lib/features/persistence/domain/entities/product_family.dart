class ProductFamily {
  final int? id;
  final String name;
  final bool isActive;

  const ProductFamily({
    this.id,
    required this.name,
    this.isActive = true,
  });
}
