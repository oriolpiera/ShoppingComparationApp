import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../../../core/normalization/family_unit_normalization.dart';
import '../../../supermarkets/data/models/supermarket.dart';
import '../../domain/entities/optimized_shopping.dart';
import '../../domain/entities/barcode_match_result.dart';
import '../../domain/entities/external_price_observation.dart';
import '../../domain/entities/external_store_mapping.dart';
import '../../domain/entities/product_family.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/entities/scanned_price_registration_result.dart';
import '../../domain/entities/shopping_list_entry.dart';
import '../../domain/external_observation_review_policy.dart';
import '../../domain/shopping_list_optimizer.dart';
import '../../domain/repositories/persistence_repository.dart';

class DriftPersistenceRepository implements PersistenceRepository {
  final PersistenceDao dao;
  static const double _priceEpsilon = 1e-9;

  DriftPersistenceRepository(this.dao);

  factory DriftPersistenceRepository.fromDatabase(AppDriftDatabase db) {
    return DriftPersistenceRepository(PersistenceDao(db));
  }

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async {
    final rows = await dao.getSupermarkets(onlyActive: onlyActive);
    return rows
        .map(
          (row) => Supermarket(
            id: row.id,
            name: row.nom,
            address: row.adreca,
            isActive: row.actiu,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveSupermarket(Supermarket supermarket) {
    return dao.saveSupermarket(
      SupermarketTableCompanion(
        id: supermarket.id == null
            ? const Value.absent()
            : Value(supermarket.id!),
        nom: Value(supermarket.name),
        adreca: Value(supermarket.address),
        actiu: Value(supermarket.isActive),
      ),
    );
  }

  @override
  Future<List<ProductFamily>> getProductFamilies(
      {bool onlyActive = true}) async {
    final rows = await dao.getProductFamilies(onlyActive: onlyActive);
    return rows
        .map(
          (row) => ProductFamily(
            id: row.id,
            name: row.nom,
            isActive: row.actiu,
            shoppingUnit: row.shoppingUnit,
            purchaseMode: row.purchaseMode,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveProductFamily(ProductFamily family) {
    return dao.saveProductFamily(
      ProductFamilyTableCompanion(
        id: family.id == null ? const Value.absent() : Value(family.id!),
        nom: Value(family.name),
        actiu: Value(family.isActive),
        shoppingUnit: Value(
          family.shoppingUnit == null
              ? null
              : normalizeShoppingUnitForStorage(family.shoppingUnit),
        ),
        purchaseMode: Value(
          family.purchaseMode == null
              ? null
              : normalizePurchaseModeForStorage(family.purchaseMode),
        ),
      ),
    );
  }

  @override
  Future<int> resolveProductFamilyIdByName(String familyName) async {
    return _resolveProductFamilyIdByName(familyName);
  }

  Future<int> _resolveProductFamilyIdByName(
    String familyName, {
    String? shoppingUnit,
    String? purchaseMode,
  }) async {
    final normalizedTarget = normalizeFamilyKey(familyName);
    final families = await getProductFamilies(onlyActive: true);
    for (final family in families) {
      if (family.id != null &&
          normalizeFamilyKey(family.name) == normalizedTarget) {
        final nextShoppingUnit = shoppingUnit == null
            ? family.shoppingUnit
            : normalizeShoppingUnitForStorage(shoppingUnit);
        final nextPurchaseMode = purchaseMode == null
            ? family.purchaseMode
            : normalizePurchaseModeForStorage(purchaseMode);

        if (family.shoppingUnit == null && nextShoppingUnit != null ||
            family.purchaseMode == null && nextPurchaseMode != null) {
          await saveProductFamily(
            ProductFamily(
              id: family.id,
              name: family.name,
              isActive: family.isActive,
              shoppingUnit: family.shoppingUnit ?? nextShoppingUnit,
              purchaseMode: family.purchaseMode ?? nextPurchaseMode,
            ),
          );
        }

        return family.id!;
      }
    }

    return saveProductFamily(
      ProductFamily(
        name: familyName.trim(),
        isActive: true,
        shoppingUnit: shoppingUnit == null
            ? null
            : normalizeShoppingUnitForStorage(shoppingUnit),
        purchaseMode: purchaseMode == null
            ? null
            : normalizePurchaseModeForStorage(purchaseMode),
      ),
    );
  }

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async {
    final rows = await dao.getProductItems(
      productFamilyId: productFamilyId,
      supermarketId: supermarketId,
      onlyCurrentPrice: onlyCurrentPrice,
    );

    return rows
        .map(
          (row) => ProductItem(
            id: row.id,
            name: row.nom,
            isActive: row.actiu,
            productFamilyId: row.productFamilyId,
            supermarketId: row.supermarketId,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            dateAdded: row.dateAdded,
            isCurrentPrice: row.isCurrentPrice,
            barcode: row.barcode,
            packageQuantityAmount: row.packageQuantityAmount,
            packageQuantityUnit: row.packageQuantityUnit,
            normalizedMeasurementUnit: row.normalizedMeasurementUnit,
            externalObservationId: row.externalObservationId,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveProductItem(ProductItem item) {
    return dao.saveProductItem(
      ProductItemTableCompanion(
        id: item.id == null ? const Value.absent() : Value(item.id!),
        nom: Value(item.name),
        actiu: Value(item.isActive),
        productFamilyId: Value(item.productFamilyId),
        supermarketId: Value(item.supermarketId),
        price: Value(item.price),
        quantity: Value(item.quantity),
        unitType: Value(item.unitType),
        pricePerQuantity: Value(item.pricePerQuantity),
        packageQuantityAmount: Value(item.packageQuantityAmount),
        packageQuantityUnit: Value(item.packageQuantityUnit),
        normalizedMeasurementUnit: Value(item.normalizedMeasurementUnit),
        dateAdded: Value(item.dateAdded),
        isCurrentPrice: Value(item.isCurrentPrice),
        barcode: Value(item.barcode),
        externalObservationId: Value(item.externalObservationId),
      ),
    );
  }

  @override
  Future<int?> getLastUsedSupermarketId() async {
    final rows = await dao.getProductItems(onlyCurrentPrice: false);
    if (rows.isEmpty) return null;
    return rows.first.supermarketId;
  }

  @override
  Future<int> saveQuickProductItem({
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? barcode,
  }) async {
    final trimmedName = productName.trim();
    final familyId = await _resolveProductFamilyIdByName(
      familyName,
      shoppingUnit: inferShoppingUnitFromUnitType(unitType),
      purchaseMode: inferPurchaseModeFromUnitType(unitType),
    );

    final currentRows = await dao.getProductItems(
      productFamilyId: familyId,
      supermarketId: supermarketId,
      onlyCurrentPrice: true,
    );

    final normalizedProduct = normalizeFamilyKey(trimmedName);
    for (final row in currentRows) {
      if (normalizeFamilyKey(row.nom) == normalizedProduct) {
        await dao.saveProductItem(
          ProductItemTableCompanion(
            id: Value(row.id),
            nom: Value(row.nom),
            actiu: Value(row.actiu),
            productFamilyId: Value(row.productFamilyId),
            supermarketId: Value(row.supermarketId),
            price: Value(row.price),
            quantity: Value(row.quantity),
            unitType: Value(row.unitType),
            pricePerQuantity: Value(row.pricePerQuantity),
            packageQuantityAmount: Value(row.packageQuantityAmount),
            packageQuantityUnit: Value(row.packageQuantityUnit),
            normalizedMeasurementUnit: Value(row.normalizedMeasurementUnit),
            dateAdded: Value(row.dateAdded),
            isCurrentPrice: const Value(false),
            barcode: Value(row.barcode),
            externalObservationId: Value(row.externalObservationId),
          ),
        );
      }
    }

    return saveProductItem(
      ProductItem(
        name: trimmedName,
        isActive: true,
        productFamilyId: familyId,
        supermarketId: supermarketId,
        price: price,
        quantity: quantity,
        unitType: normalizeUnitTypeForStorage(unitType),
        pricePerQuantity: quantity == 0 ? 0 : price / quantity,
        packageQuantityAmount: quantity,
        packageQuantityUnit: normalizeUnitTypeForStorage(unitType),
        normalizedMeasurementUnit: normalizeUnitTypeForComparison(unitType),
        dateAdded: DateTime.now(),
        isCurrentPrice: true,
        barcode: barcode,
      ),
    );
  }

  @override
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
      String barcode) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return const [];

    final rows = await dao.getCurrentActiveItemsByBarcode(normalized);
    if (rows.isEmpty) return const [];

    final families = await getProductFamilies(onlyActive: false);
    final supermarkets = await getSupermarkets(onlyActive: false);

    final familyNameById = {
      for (final family in families)
        if (family.id != null) family.id!: family.name,
    };
    final supermarketNameById = {
      for (final market in supermarkets)
        if (market.id != null) market.id!: market.name,
    };

    final items = rows
        .map(
          (row) => ProductItem(
            id: row.id,
            name: row.nom,
            isActive: row.actiu,
            productFamilyId: row.productFamilyId,
            supermarketId: row.supermarketId,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            dateAdded: row.dateAdded,
            isCurrentPrice: row.isCurrentPrice,
            barcode: row.barcode,
            packageQuantityAmount: row.packageQuantityAmount,
            packageQuantityUnit: row.packageQuantityUnit,
            normalizedMeasurementUnit: row.normalizedMeasurementUnit,
            externalObservationId: row.externalObservationId,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byCurrent =
            (b.isCurrentPrice ? 1 : 0) - (a.isCurrentPrice ? 1 : 0);
        if (byCurrent != 0) return byCurrent;

        final byDate = b.dateAdded.compareTo(a.dateAdded);
        if (byDate != 0) return byDate;

        final byUnit = a.pricePerQuantity.compareTo(b.pricePerQuantity);
        if (byUnit != 0) return byUnit;

        return a.price.compareTo(b.price);
      });

    return items
        .map(
          (item) => BarcodeMatchResult(
            productItem: item,
            familyName:
                familyNameById[item.productFamilyId] ?? 'Unknown family',
            supermarketName: supermarketNameById[item.supermarketId] ??
                'Unknown supermarket',
          ),
        )
        .toList();
  }

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
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      return const ScannedPriceRegistrationResult(
        created: false,
        message: 'Barcode is required.',
      );
    }

    final currentMatches =
        await dao.getCurrentActiveItemsByBarcode(normalizedBarcode);
    final unit = normalizeUnitTypeForStorage(unitType);

    final currentSameMarket = currentMatches
        .where((row) => row.supermarketId == supermarketId)
        .toList();

    final sameTupleExists = currentSameMarket.any((row) {
      return (row.price - price).abs() < _priceEpsilon &&
          (row.quantity - quantity).abs() < _priceEpsilon &&
          normalizeUnitTypeForComparison(row.unitType) ==
              normalizeUnitTypeForComparison(unit);
    });

    if (sameTupleExists) {
      return const ScannedPriceRegistrationResult(
        created: false,
        message:
            'Price already current in this supermarket. No new Product Item created.',
      );
    }

    await dao.db.transaction(() async {
      for (final row in currentSameMarket) {
        await dao.saveProductItem(
          ProductItemTableCompanion(
            id: Value(row.id),
            nom: Value(row.nom),
            actiu: Value(row.actiu),
            productFamilyId: Value(row.productFamilyId),
            supermarketId: Value(row.supermarketId),
            price: Value(row.price),
            quantity: Value(row.quantity),
            unitType: Value(row.unitType),
            pricePerQuantity: Value(row.pricePerQuantity),
            packageQuantityAmount: Value(row.packageQuantityAmount),
            packageQuantityUnit: Value(row.packageQuantityUnit),
            normalizedMeasurementUnit: Value(row.normalizedMeasurementUnit),
            dateAdded: Value(row.dateAdded),
            isCurrentPrice: const Value(false),
            barcode: Value(row.barcode),
            externalObservationId: Value(row.externalObservationId),
          ),
        );
      }

      final familyId = await _resolveProductFamilyIdByName(
        familyName,
        shoppingUnit: inferShoppingUnitFromUnitType(unitType),
        purchaseMode: inferPurchaseModeFromUnitType(unitType),
      );
      await saveProductItem(
        ProductItem(
          name: productName.trim(),
          isActive: true,
          productFamilyId: familyId,
          supermarketId: supermarketId,
          price: price,
          quantity: quantity,
          unitType: unit,
          pricePerQuantity: quantity == 0 ? 0 : price / quantity,
          packageQuantityAmount: quantity,
          packageQuantityUnit: unit,
          normalizedMeasurementUnit: normalizeUnitTypeForComparison(unit),
          dateAdded: DateTime.now(),
          isCurrentPrice: true,
          barcode: normalizedBarcode,
          externalObservationId: null,
        ),
      );
    });

    return const ScannedPriceRegistrationResult(
      created: true,
      message: 'New current price registered.',
    );
  }

  @override
  Future<List<ExternalStoreMapping>> getExternalStoreMappings() async {
    final rows = await dao.getExternalStoreMappings();
    return rows
        .map(
          (row) => ExternalStoreMapping(
            id: row.id,
            externalStoreId: row.externalStoreId,
            externalStoreName: row.externalStoreName,
            supermarketId: row.supermarketId,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping) {
    return dao.saveExternalStoreMapping(
      ExternalStoreMappingTableCompanion(
        id: mapping.id == null ? const Value.absent() : Value(mapping.id!),
        externalStoreId: Value(mapping.externalStoreId),
        externalStoreName: Value(mapping.externalStoreName),
        supermarketId: Value(mapping.supermarketId),
      ),
    );
  }

  @override
  Future<List<ExternalPriceObservation>> getExternalPriceObservations() async {
    final rows = await dao.getExternalPriceObservations();
    return rows
        .map(
          (row) => ExternalPriceObservation(
            id: row.id,
            openPricesId: row.openPricesId,
            productName: row.productName,
            familyName: row.familyName,
            externalStoreId: row.externalStoreId,
            externalStoreName: row.externalStoreName,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            observedAt: row.observedAt,
            reviewStatus: ExternalObservationReviewStatusCodec.fromStorageValue(
              row.reviewStatus,
            ),
            localProductItemId: row.localProductItemId,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveExternalPriceObservation(
      ExternalPriceObservation observation) async {
    final existing = observation.id == null
        ? await dao.getExternalPriceObservationByOpenPricesId(
            observation.openPricesId,
          )
        : null;

    return dao.saveExternalPriceObservation(
      ExternalPriceObservationTableCompanion(
        id: observation.id != null
            ? Value(observation.id!)
            : existing == null
                ? const Value.absent()
                : Value(existing.id),
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
        reviewStatus: existing != null
            ? Value(existing.reviewStatus)
            : Value(observation.reviewStatus.storageValue),
        localProductItemId: existing != null
            ? Value(existing.localProductItemId)
            : Value(observation.localProductItemId),
      ),
    );
  }

  @override
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) async {
    final row = await dao.getExternalPriceObservationById(observationId);
    if (row == null) {
      throw StateError('External observation not found: $observationId');
    }
    final current =
        ExternalObservationReviewStatusCodec.fromStorageValue(row.reviewStatus);
    if (!canTransitionReviewStatus(from: current, to: newStatus)) {
      throw StateError(
          'Invalid review status transition: $current -> $newStatus');
    }

    await dao.saveExternalPriceObservation(
      ExternalPriceObservationTableCompanion(
        id: Value(row.id),
        openPricesId: Value(row.openPricesId),
        productName: Value(row.productName),
        familyName: Value(row.familyName),
        externalStoreId: Value(row.externalStoreId),
        externalStoreName: Value(row.externalStoreName),
        price: Value(row.price),
        quantity: Value(row.quantity),
        unitType: Value(row.unitType),
        pricePerQuantity: Value(row.pricePerQuantity),
        observedAt: Value(row.observedAt),
        reviewStatus: Value(newStatus.storageValue),
        localProductItemId: Value(row.localProductItemId),
      ),
    );
  }

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
  }) async {
    return dao.db.transaction(() async {
      final observation =
          await dao.getExternalPriceObservationById(observationId);
      if (observation == null) {
        throw StateError('External observation not found: $observationId');
      }

      if (observation.localProductItemId != null) {
        throw StateError(
          'Observation $observationId is already confirmed '
          'with local product item ${observation.localProductItemId}',
        );
      }

      final currentStatus =
          ExternalObservationReviewStatusCodec.fromStorageValue(
              observation.reviewStatus);
      if (!canTransitionReviewStatus(
        from: currentStatus,
        to: ExternalObservationReviewStatus.acceptedForComparison,
      )) {
        throw StateError(
          'Invalid review status transition: $currentStatus -> ${ExternalObservationReviewStatus.acceptedForComparison}',
        );
      }

      final mapping = await dao
          .getExternalStoreMappingByExternalId(observation.externalStoreId);
      if (mapping == null) {
        throw StateError(
            'Missing external store mapping for ${observation.externalStoreId}');
      }

      final familyId =
          await resolveProductFamilyIdByName(observation.familyName);
      final productItemId = await saveProductItem(
        ProductItem(
          name: observation.productName,
          productFamilyId: familyId,
          supermarketId: mapping.supermarketId,
          price: observation.price,
          quantity: observation.quantity,
          unitType: observation.unitType,
          pricePerQuantity: observation.pricePerQuantity,
          packageQuantityAmount: observation.quantity,
          packageQuantityUnit: observation.unitType,
          normalizedMeasurementUnit:
              normalizeUnitTypeForComparison(observation.unitType),
          dateAdded: DateTime.now(),
          isCurrentPrice: true,
          externalObservationId: observation.id,
        ),
      );

      await dao.saveExternalPriceObservation(
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
          localProductItemId: Value(productItemId),
        ),
      );

      return productItemId;
    });
  }

  @override
  Future<List<ShoppingListEntry>> getShoppingList() async {
    final rows = await dao.getShoppingList();
    return rows
        .map(
          (row) => ShoppingListEntry(
            id: row.id,
            productFamilyId: row.productFamilyId,
            quantity: row.quantity.round(),
          ),
        )
        .toList();
  }

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) {
    return dao.saveShoppingListEntry(
      ShoppingListTableCompanion(
        id: entry.id == null ? const Value.absent() : Value(entry.id!),
        productFamilyId: Value(entry.productFamilyId),
        quantity: Value(entry.quantity),
        productItemId: const Value.absent(),
      ),
    );
  }

  @override
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async {
    final existing = await dao.getShoppingListEntryByFamily(productFamilyId);
    if (existing != null) {
      final updatedId = await saveShoppingListEntry(
        ShoppingListEntry(
          id: existing.id,
          productFamilyId: existing.productFamilyId,
          quantity: existing.quantity.round() + quantity,
        ),
      );
      final check = await dao.getShoppingListEntryByFamily(productFamilyId);
      if (check == null) {
        throw StateError('ShoppingList entry disappeared after update');
      }
      return updatedId;
    }

    final insertedId = await saveShoppingListEntry(
      ShoppingListEntry(
        productFamilyId: productFamilyId,
        quantity: quantity,
      ),
    );
    final check = await dao.getShoppingListEntryByFamily(productFamilyId);
    if (check == null) {
      throw StateError('ShoppingList entry not found after insert');
    }
    return insertedId;
  }

  @override
  Future<void> deleteShoppingListEntries(List<int> entryIds) {
    return dao.deleteShoppingListEntriesByIds(entryIds);
  }

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async {
    final shoppingList = await getShoppingList();
    final families = await getProductFamilies(onlyActive: false);
    final supermarkets = await getSupermarkets(onlyActive: true);
    final items = await getProductItems(onlyCurrentPrice: true);
    final familyById = {
      for (final family in families)
        if (family.id != null) family.id!: family,
    };
    final familyIdByName = {
      for (final family in families)
        if (family.id != null) normalizeFamilyKey(family.name): family.id!,
    };

    final externalRows = await dao.getExternalPriceObservations();
    final mappings = await dao.getExternalStoreMappings();
    final mappingByExternalStoreId = {
      for (final mapping in mappings) mapping.externalStoreId: mapping,
    };

    final acceptedExternalItems = externalRows
        .where(
          (row) =>
              row.reviewStatus ==
                  ExternalObservationReviewStatus
                      .acceptedForComparison.storageValue &&
              row.localProductItemId == null,
        )
        .map((row) {
          final mapping = mappingByExternalStoreId[row.externalStoreId];
          final familyId = familyIdByName[normalizeFamilyKey(row.familyName)];
          if (mapping == null || familyId == null) return null;
          return ProductItem(
            id: row.localProductItemId,
            name: row.productName,
            productFamilyId: familyId,
            supermarketId: mapping.supermarketId,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            dateAdded: row.observedAt,
            isCurrentPrice: true,
            externalObservationId: row.id,
          );
        })
        .whereType<ProductItem>()
        .toList();
    final supermarketNameById = {
      for (final market in supermarkets)
        if (market.id != null) market.id!: market.name,
    };
    final optimization = optimizeShoppingList(
      shoppingList: shoppingList,
      familyById: familyById,
      supermarketNameById: supermarketNameById,
      items: [
        ...items,
        ...acceptedExternalItems.where((i) => i.productFamilyId > 0)
      ],
    );

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
}
