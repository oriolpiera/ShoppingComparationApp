import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../../../core/normalization/family_normalization.dart';
import '../../../../core/normalization/unit_normalization.dart';
import '../../domain/entities/barcode_match_result.dart';
import '../../domain/entities/external_price_observation.dart';
import '../../domain/entities/external_store_mapping.dart';
import '../../domain/entities/optimized_shopping.dart';
import '../../domain/entities/product_family.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/entities/scanned_price_registration_result.dart';
import '../../domain/entities/shopping_list_entry.dart';
import '../../domain/entities/supermarket.dart';
import '../../domain/repositories/persistence_repository.dart';
import '../../domain/shopping_list_optimizer.dart';
import 'drift_backup_repository.dart';
import 'drift_external_observation_repository.dart';
import 'drift_price_record_repository.dart';
import 'drift_product_family_repository.dart';
import 'drift_shopping_list_repository.dart';
import 'drift_supermarket_repository.dart';

class DriftPersistenceRepository implements PersistenceRepository {
  final DriftSupermarketRepository _supermarketRepository;
  final DriftProductFamilyRepository _productFamilyRepository;
  final DriftPriceRecordRepository _priceRecordRepository;
  final DriftShoppingListRepository _shoppingListRepository;
  final DriftExternalObservationRepository _externalObservationRepository;
  final DriftBackupRepository _backupRepository;

  DriftPersistenceRepository._({
    required DriftSupermarketRepository supermarketRepository,
    required DriftProductFamilyRepository productFamilyRepository,
    required DriftPriceRecordRepository priceRecordRepository,
    required DriftShoppingListRepository shoppingListRepository,
    required DriftExternalObservationRepository externalObservationRepository,
    required DriftBackupRepository backupRepository,
  })  : _supermarketRepository = supermarketRepository,
        _productFamilyRepository = productFamilyRepository,
        _priceRecordRepository = priceRecordRepository,
        _shoppingListRepository = shoppingListRepository,
        _externalObservationRepository = externalObservationRepository,
        _backupRepository = backupRepository;

  factory DriftPersistenceRepository(PersistenceDao dao) {
    return DriftPersistenceRepository._(
      supermarketRepository: DriftSupermarketRepository(dao),
      productFamilyRepository: DriftProductFamilyRepository(dao),
      priceRecordRepository: DriftPriceRecordRepository(dao),
      shoppingListRepository: DriftShoppingListRepository(dao),
      externalObservationRepository: DriftExternalObservationRepository(dao),
      backupRepository: DriftBackupRepository(dao),
    );
  }

  factory DriftPersistenceRepository.fromDatabase(AppDriftDatabase db) {
    return DriftPersistenceRepository(PersistenceDao(db));
  }

  // ---------------------------------------------------------------------------
  // Backup
  // ---------------------------------------------------------------------------

  @override
  Future<String> exportBackupJson() => _backupRepository.exportBackupJson();

  @override
  Future<void> importBackupJson(String jsonPayload) =>
      _backupRepository.importBackupJson(jsonPayload);

  // ---------------------------------------------------------------------------
  // Supermarkets
  // ---------------------------------------------------------------------------

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) =>
      _supermarketRepository.getSupermarkets(onlyActive: onlyActive);

  @override
  Future<int> saveSupermarket(Supermarket supermarket) =>
      _supermarketRepository.saveSupermarket(supermarket);

  // ---------------------------------------------------------------------------
  // Product Families
  // ---------------------------------------------------------------------------

  @override
  Future<List<ProductFamily>> getProductFamilies({bool onlyActive = true}) =>
      _productFamilyRepository.getProductFamilies(onlyActive: onlyActive);

  @override
  Future<int> saveProductFamily(ProductFamily family) =>
      _productFamilyRepository.saveProductFamily(family);

  @override
  Future<int> resolveProductFamilyIdByName(String familyName) =>
      _productFamilyRepository.resolveProductFamilyIdByName(familyName);

  @override
  Future<List<ProductFamily>> getActiveShoppingFamilies() =>
      _productFamilyRepository.getActiveShoppingFamilies();

  // ---------------------------------------------------------------------------
  // Product Items / Price Records
  // ---------------------------------------------------------------------------

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) =>
      _priceRecordRepository.getProductItems(
        productFamilyId: productFamilyId,
        supermarketId: supermarketId,
        onlyCurrentPrice: onlyCurrentPrice,
      );

  @override
  Future<int> saveProductItem(ProductItem item) =>
      _priceRecordRepository.saveProductItem(item);

  @override
  Future<int?> getLastUsedSupermarketId() =>
      _priceRecordRepository.getLastUsedSupermarketId();

  @override
  Future<int> saveQuickProductItem({
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? purchaseMode,
    String? barcode,
  }) async {
    final familyId =
        await _productFamilyRepository.resolveOrCreateProductFamily(
      familyName,
      shoppingUnit: inferShoppingUnitFromUnitType(unitType),
      purchaseMode: purchaseMode ?? inferPurchaseModeFromUnitType(unitType),
    );
    return _priceRecordRepository.saveQuickProductItem(
      productName: productName,
      familyId: familyId,
      supermarketId: supermarketId,
      price: price,
      quantity: quantity,
      unitType: unitType,
      purchaseMode: purchaseMode,
      barcode: barcode,
    );
  }

  @override
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
    String barcode,
  ) =>
      _priceRecordRepository.findCurrentActiveByBarcode(barcode);

  @override
  Future<ScannedPriceRegistrationResult> registerScannedPrice({
    required String barcode,
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
  }) async {
    final familyId =
        await _productFamilyRepository.resolveOrCreateProductFamily(
      familyName,
      shoppingUnit: inferShoppingUnitFromUnitType(unitType),
      purchaseMode: inferPurchaseModeFromUnitType(unitType),
    );
    return _priceRecordRepository.registerScannedPrice(
      barcode: barcode,
      productName: productName,
      familyId: familyId,
      supermarketId: supermarketId,
      price: price,
      quantity: quantity,
      unitType: unitType,
    );
  }

  // ---------------------------------------------------------------------------
  // External Observations / Store Mappings
  // ---------------------------------------------------------------------------

  @override
  Future<List<ExternalStoreMapping>> getExternalStoreMappings() =>
      _externalObservationRepository.getExternalStoreMappings();

  @override
  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping) =>
      _externalObservationRepository.saveExternalStoreMapping(mapping);

  @override
  Future<List<ExternalPriceObservation>> getExternalPriceObservations() =>
      _externalObservationRepository.getExternalPriceObservations();

  @override
  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  ) =>
      _externalObservationRepository.saveExternalPriceObservation(observation);

  @override
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) =>
      _externalObservationRepository.updateExternalObservationReviewStatus(
        observationId: observationId,
        newStatus: newStatus,
      );

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
  }) async {
    return _externalObservationRepository.dao.db.transaction(() async {
      final observation = await _externalObservationRepository.dao
          .getExternalPriceObservationById(observationId);
      if (observation == null) {
        throw StateError('External observation not found: $observationId');
      }

      final mapping = await _externalObservationRepository.dao
          .getExternalStoreMappingByExternalId(observation.externalStoreId);

      final confirmationObservation = ExternalPriceObservation(
        id: observation.id,
        openPricesId: observation.openPricesId,
        productName: observation.productName,
        familyName: observation.familyName,
        externalStoreId: observation.externalStoreId,
        externalStoreName: observation.externalStoreName,
        price: observation.price,
        quantity: observation.quantity,
        unitType: observation.unitType,
        pricePerQuantity: observation.pricePerQuantity,
        observedAt: observation.observedAt,
        reviewStatus: ExternalObservationReviewStatusCodec.fromStorageValue(
          observation.reviewStatus,
        ),
        localProductItemId: observation.localProductItemId,
        localPriceRecordId: observation.localPriceRecordId,
      );
      final familyId =
          await _productFamilyRepository.resolveProductFamilyIdByName(
        observation.familyName,
      );
      final confirmationPlan =
          _externalObservationRepository.confirmationPlanner.buildPlan(
        observation: confirmationObservation,
        mapping: mapping == null
            ? null
            : ExternalStoreMapping(
                id: mapping.id,
                externalStoreId: mapping.externalStoreId,
                externalStoreName: mapping.externalStoreName,
                supermarketId: mapping.supermarketId,
              ),
        productFamilyId: familyId,
        confirmedAt: DateTime.now(),
      );
      final productItemId = await _priceRecordRepository.saveProductItem(
        confirmationPlan.localPriceRecord,
      );

      await _externalObservationRepository.dao.saveExternalPriceObservation(
        ExternalPriceObservationTableCompanion(
          id: Value(observation.id),
          openPricesId: Value(observation.openPricesId),
          productName: Value(observation.productName),
          familyName: Value(observation.familyName),
          externalStoreId: Value(observation.externalStoreId),
          externalStoreName: Value(observation.externalStoreName),
          price: Value(observation.price),
          quantity: Value(observation.quantity),
          unitType: Value(observation.unitType),
          pricePerQuantity: Value(observation.pricePerQuantity),
          observedAt: Value(observation.observedAt),
          reviewStatus: Value(
            ExternalObservationReviewStatus.acceptedForComparison.storageValue,
          ),
          localProductItemId: Value(observation.localProductItemId),
          localPriceRecordId: Value(productItemId),
        ),
      );

      return productItemId;
    });
  }

  // ---------------------------------------------------------------------------
  // Shopping List
  // ---------------------------------------------------------------------------

  @override
  Future<List<ShoppingListEntry>> getShoppingList() =>
      _shoppingListRepository.getShoppingList();

  @override
  Future<List<ShoppingListEntry>> getShoppingNeedEntries() =>
      _shoppingListRepository.getShoppingList();

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) =>
      _shoppingListRepository.saveShoppingListEntry(entry);

  @override
  Future<int> saveShoppingNeedEntry(ShoppingListEntry entry) =>
      _shoppingListRepository.saveShoppingListEntry(entry);

  @override
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) =>
      _shoppingListRepository.addOrIncrementShoppingListEntry(
        productFamilyId: productFamilyId,
        quantity: quantity,
      );

  @override
  Future<int> addOrIncrementShoppingNeedEntry({
    required int productFamilyId,
    int quantity = 1,
  }) =>
      _shoppingListRepository.addOrIncrementShoppingListEntry(
        productFamilyId: productFamilyId,
        quantity: quantity,
      );

  @override
  Future<void> deleteShoppingListEntries(List<int> entryIds) =>
      _shoppingListRepository.deleteShoppingListEntries(entryIds);

  @override
  Future<void> deleteShoppingNeedEntries(List<int> entryIds) =>
      _shoppingListRepository.deleteShoppingListEntries(entryIds);

  // ---------------------------------------------------------------------------
  // Optimisation (cross-domain orchestration)
  // ---------------------------------------------------------------------------

  @override
  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries() async {
    final shoppingList = await getShoppingNeedEntries();
    final families = await _productFamilyRepository.getProductFamilies(
      onlyActive: false,
    );
    final supermarkets = await _supermarketRepository.getSupermarkets(
      onlyActive: true,
    );
    final items = await _priceRecordRepository.getProductItems(
      onlyCurrentPrice: true,
    );
    final familyById = {
      for (final family in families)
        if (family.id != null) family.id!: family,
    };
    final familyIdByName = {
      for (final family in families)
        if (family.id != null) normalizeFamilyKey(family.name): family.id!,
    };

    final externalRows =
        await _externalObservationRepository.dao.getExternalPriceObservations();
    final mappings =
        await _externalObservationRepository.dao.getExternalStoreMappings();
    final mappingByExternalStoreId = {
      for (final mapping in mappings) mapping.externalStoreId: mapping,
    };

    final acceptedExternalItems = externalRows
        .where(
          (row) =>
              row.reviewStatus ==
                  ExternalObservationReviewStatus
                      .acceptedForComparison.storageValue &&
              row.localPriceRecordId == null,
        )
        .map((row) {
          final mapping = mappingByExternalStoreId[row.externalStoreId];
          final familyId = familyIdByName[normalizeFamilyKey(row.familyName)];
          if (mapping == null || familyId == null) return null;
          return ProductItem(
            id: row.localPriceRecordId,
            name: row.productName,
            productFamilyId: familyId,
            supermarketId: mapping.supermarketId,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            dateAdded: row.observedAt,
            isCurrentPrice: true,
            packageQuantityAmount: row.quantity,
            packageQuantityUnit: row.unitType,
            normalizedMeasurementUnit: normalizeUnitTypeForComparison(
              row.unitType,
            ),
            externalObservationId: row.id,
          );
        })
        .whereType<ProductItem>()
        .toList();
    final supermarketNameById = {
      for (final market in supermarkets)
        if (market.id != null) market.id!: market.name,
    };

    return optimizeShoppingList(
      shoppingList: shoppingList,
      familyById: familyById,
      supermarketNameById: supermarketNameById,
      items: [
        ...items,
        ...acceptedExternalItems.where((i) => i.productFamilyId > 0),
      ],
    );
  }

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async {
    final optimization = await getOptimizedShoppingNeedEntries();

    final result = optimization.groups
        .map(
          (group) => OptimizedShoppingGroup(
            supermarketId: group.supermarketId,
            supermarketName: group.supermarketName,
            items: group.entries
                .map(
                  (entry) => OptimizedShoppingItem(
                    shoppingListEntryId: entry.shoppingListEntryId,
                    productFamilyId: entry.productFamilyId,
                    productFamilyName: entry.productFamilyName,
                    quantity: entry.quantity,
                    bestItem: entry.bestItem,
                    estimatedCost: entry.estimatedCost,
                    sourceTag:
                        entry.bestItem.isOpenPricesSource ? 'OpenPrices' : null,
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return result;
  }

  // ---------------------------------------------------------------------------
  // Exposed sub-repositories for selective dependency injection
  // ---------------------------------------------------------------------------

  DriftSupermarketRepository get supermarketRepository =>
      _supermarketRepository;
  DriftProductFamilyRepository get productFamilyRepository =>
      _productFamilyRepository;
  DriftPriceRecordRepository get priceRecordRepository =>
      _priceRecordRepository;
  DriftShoppingListRepository get shoppingListRepository =>
      _shoppingListRepository;
  DriftExternalObservationRepository get externalObservationRepository =>
      _externalObservationRepository;
  DriftBackupRepository get backupRepository => _backupRepository;
}
