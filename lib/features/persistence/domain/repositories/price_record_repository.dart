import '../entities/barcode_match_result.dart';
import '../entities/scanned_price_registration_result.dart';

abstract class PriceRecordRepository {
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(String barcode);

  Future<ScannedPriceRegistrationResult> registerScannedPrice({
    required String barcode,
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
  });
}
