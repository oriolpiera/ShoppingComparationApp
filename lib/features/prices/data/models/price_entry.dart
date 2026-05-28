class PriceEntry {
  int? id;
  int productId;
  int supermarketId;
  double price;
  DateTime capturedAt;

  PriceEntry({
    this.id,
    this.productId = 0,
    this.supermarketId = 0,
    this.price = 0,
    DateTime? capturedAt,
  }) : capturedAt = capturedAt ?? DateTime.now();
}
