import 'catalog_product.dart';
import 'price_record.dart';

class ScannedPriceRegistrationResult {
  const ScannedPriceRegistrationResult({
    required this.created,
    required this.catalogProduct,
    required this.priceRecord,
    this.message,
  });

  final bool created;
  final CatalogProduct catalogProduct;
  final PriceRecord priceRecord;
  final String? message;
}
