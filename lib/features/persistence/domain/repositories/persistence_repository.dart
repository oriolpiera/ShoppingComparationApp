import '../entities/optimized_shopping.dart';
import '../entities/barcode_match_result.dart';
import '../entities/external_price_observation.dart';
import '../entities/external_store_mapping.dart';
import '../entities/product_family.dart';
import '../entities/product_item.dart';
import '../entities/scanned_price_registration_result.dart';
import '../entities/shopping_list_entry.dart';
import '../../../supermarkets/data/models/supermarket.dart';

abstract class PersistenceRepository {
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true});
  Future<int> saveSupermarket(Supermarket supermarket);

  Future<List<ProductFamily>> getProductFamilies({bool onlyActive = true});
  Future<int> saveProductFamily(ProductFamily family);
  Future<int> resolveProductFamilyIdByName(String familyName);

  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  });
  Future<int> saveProductItem(ProductItem item);
  Future<int?> getLastUsedSupermarketId();
  Future<int> saveQuickProductItem({
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? purchaseMode,
    String? barcode,
  });
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

  Future<List<ExternalStoreMapping>> getExternalStoreMappings();
  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping);
  Future<List<ExternalPriceObservation>> getExternalPriceObservations();
  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  );
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  });
  Future<int> confirmExternalObservationLocally({required int observationId});

  Future<List<ShoppingListEntry>> getShoppingList();
  Future<int> saveShoppingListEntry(ShoppingListEntry entry);
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  });
  Future<void> deleteShoppingListEntries(List<int> entryIds);
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList();
}
