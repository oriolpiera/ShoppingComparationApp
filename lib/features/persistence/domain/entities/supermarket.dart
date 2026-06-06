class Supermarket {
  final int? id;
  final String name;
  final String? address;
  final bool isActive;

  const Supermarket({
    this.id,
    required this.name,
    this.address,
    this.isActive = true,
  });
}
