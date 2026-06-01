class ExternalStoreMapping {
  const ExternalStoreMapping({
    this.id,
    required this.externalStoreId,
    required this.externalStoreName,
    required this.supermarketId,
  });

  final int? id;
  final String externalStoreId;
  final String externalStoreName;
  final int supermarketId;
}
