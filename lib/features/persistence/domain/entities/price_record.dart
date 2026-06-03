class PriceRecord {
  const PriceRecord({
    this.id,
    required this.catalogProductId,
    required this.supermarketId,
    required this.price,
    required this.observedAt,
    this.isActive = true,
    this.externalObservationId,
  });

  final int? id;
  final int catalogProductId;
  final int supermarketId;
  final double price;
  final DateTime observedAt;
  final bool isActive;
  final int? externalObservationId;
}
