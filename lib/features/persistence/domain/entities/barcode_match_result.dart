import 'product_item.dart';

class BarcodeMatchResult {
  const BarcodeMatchResult({
    required this.productItem,
    required this.familyName,
    required this.supermarketName,
  });

  final ProductItem productItem;
  final String familyName;
  final String supermarketName;
}
