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
  Future<List<ProductFamily>> getProductFamilies({
    bool onlyActive = true,
  }) async {
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

  Future<List<ProductItem>> _getDerivedProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
    String? barcode,
  }) async {
    final filters = <String>[];
    final variables = <Variable<Object>>[];

    if (productFamilyId != null) {
      filters.add('cp.product_family_id = ?');
      variables.add(Variable.withInt(productFamilyId));
    }
    if (supermarketId != null) {
      filters.add('pr.supermarket_id = ?');
      variables.add(Variable.withInt(supermarketId));
    }
    if (barcode != null && barcode.trim().isNotEmpty) {
      filters.add('cp.barcode = ?');
      variables.add(Variable.withString(barcode.trim()));
    }
    if (onlyCurrentPrice) {
      filters.add(_isCurrentPriceSql(alias: 'pr'));
    }

    final whereClause = filters.isEmpty ? '' : 'WHERE ${filters.join(' AND ')}';

    final rows = await dao.db.customSelect(
      '''
      SELECT
        pr.id AS price_record_id,
        cp.nom AS product_name,
        cp.actiu AS catalog_active,
        cp.product_family_id,
        cp.barcode,
        cp.package_quantity_amount,
        cp.package_quantity_unit,
        cp.normalized_measurement_unit,
        pr.supermarket_id,
        pr.price,
        pr.observed_at,
        pr.actiu AS price_record_active,
        pr.external_observation_id,
        CASE WHEN ${_isCurrentPriceSql(alias: 'pr')} THEN 1 ELSE 0 END AS is_current_price
      FROM price_record pr
      JOIN catalog_product cp ON cp.id = pr.catalog_product_id
      $whereClause
      ORDER BY pr.observed_at DESC, pr.id DESC;
      ''',
      variables: variables,
    ).get();

    return rows.map(
      (row) {
        final quantity =
            (row.data['package_quantity_amount'] as num?)?.toDouble() ?? 0;
        final price = row.read<double>('price');
        final unitType = (row.data['package_quantity_unit'] as String?) ??
            (row.data['normalized_measurement_unit'] as String?) ??
            'kg';
        return ProductItem(
          id: row.read<int>('price_record_id'),
          name: row.read<String>('product_name'),
          isActive: (row.data['catalog_active'] as int? ?? 0) == 1 &&
              (row.data['price_record_active'] as int? ?? 0) == 1,
          productFamilyId: row.read<int>('product_family_id'),
          supermarketId: row.read<int>('supermarket_id'),
          price: price,
          quantity: quantity,
          unitType: unitType,
          pricePerQuantity: quantity == 0 ? 0 : price / quantity,
          dateAdded: DateTime.fromMillisecondsSinceEpoch(
            (row.data['observed_at'] as int?) ?? 0,
          ),
          isCurrentPrice: (row.data['is_current_price'] as int? ?? 0) == 1,
          barcode: row.data['barcode'] as String?,
          packageQuantityAmount: quantity,
          packageQuantityUnit: unitType,
          normalizedMeasurementUnit:
              row.data['normalized_measurement_unit'] as String?,
          externalObservationId: row.data['external_observation_id'] as int?,
        );
      },
    ).toList();
  }

  String _isCurrentPriceSql({required String alias}) {
    return '''
      NOT EXISTS (
        SELECT 1
        FROM price_record newer
        WHERE newer.catalog_product_id = $alias.catalog_product_id
          AND newer.supermarket_id = $alias.supermarket_id
          AND (
            newer.observed_at > $alias.observed_at OR
            (newer.observed_at = $alias.observed_at AND newer.id > $alias.id)
          )
      )
    ''';
  }

  Future<_PriceRecordSnapshot?> _getPriceRecordById(int priceRecordId) async {
    final row = await dao.db.customSelect(
      '''
      SELECT
        pr.id,
        pr.catalog_product_id,
        pr.supermarket_id,
        pr.price,
        pr.observed_at,
        pr.actiu,
        pr.external_observation_id,
        cp.nom,
        cp.actiu AS catalog_actiu,
        cp.product_family_id,
        cp.barcode,
        cp.package_quantity_amount,
        cp.package_quantity_unit,
        cp.normalized_measurement_unit
      FROM price_record pr
      JOIN catalog_product cp ON cp.id = pr.catalog_product_id
      WHERE pr.id = ?
      LIMIT 1;
      ''',
      variables: [Variable.withInt(priceRecordId)],
    ).getSingleOrNull();
    if (row == null) return null;

    return _PriceRecordSnapshot(
      id: row.read<int>('id'),
      catalogProductId: row.read<int>('catalog_product_id'),
      supermarketId: row.read<int>('supermarket_id'),
      price: row.read<double>('price'),
      observedAt: DateTime.fromMillisecondsSinceEpoch(
        (row.data['observed_at'] as int?) ?? 0,
      ),
      isActive: (row.data['actiu'] as int? ?? 0) == 1,
      catalogIsActive: (row.data['catalog_actiu'] as int? ?? 0) == 1,
      externalObservationId: row.data['external_observation_id'] as int?,
      name: row.read<String>('nom'),
      productFamilyId: row.read<int>('product_family_id'),
      barcode: row.data['barcode'] as String?,
      packageQuantityAmount:
          (row.data['package_quantity_amount'] as num?)?.toDouble(),
      packageQuantityUnit: row.data['package_quantity_unit'] as String?,
      normalizedMeasurementUnit:
          row.data['normalized_measurement_unit'] as String?,
    );
  }

  Future<_PriceRecordSnapshot?> _getLatestPriceRecord({
    required int catalogProductId,
    required int supermarketId,
  }) async {
    final row = await dao.db.customSelect(
      '''
      SELECT
        pr.id,
        pr.catalog_product_id,
        pr.supermarket_id,
        pr.price,
        pr.observed_at,
        pr.actiu,
        pr.external_observation_id,
        cp.nom,
        cp.actiu AS catalog_actiu,
        cp.product_family_id,
        cp.barcode,
        cp.package_quantity_amount,
        cp.package_quantity_unit,
        cp.normalized_measurement_unit
      FROM price_record pr
      JOIN catalog_product cp ON cp.id = pr.catalog_product_id
      WHERE pr.catalog_product_id = ? AND pr.supermarket_id = ?
      ORDER BY pr.observed_at DESC, pr.id DESC
      LIMIT 1;
      ''',
      variables: [
        Variable.withInt(catalogProductId),
        Variable.withInt(supermarketId),
      ],
    ).getSingleOrNull();
    if (row == null) return null;

    return _PriceRecordSnapshot(
      id: row.read<int>('id'),
      catalogProductId: row.read<int>('catalog_product_id'),
      supermarketId: row.read<int>('supermarket_id'),
      price: row.read<double>('price'),
      observedAt: DateTime.fromMillisecondsSinceEpoch(
        (row.data['observed_at'] as int?) ?? 0,
      ),
      isActive: (row.data['actiu'] as int? ?? 0) == 1,
      catalogIsActive: (row.data['catalog_actiu'] as int? ?? 0) == 1,
      externalObservationId: row.data['external_observation_id'] as int?,
      name: row.read<String>('nom'),
      productFamilyId: row.read<int>('product_family_id'),
      barcode: row.data['barcode'] as String?,
      packageQuantityAmount:
          (row.data['package_quantity_amount'] as num?)?.toDouble(),
      packageQuantityUnit: row.data['package_quantity_unit'] as String?,
      normalizedMeasurementUnit:
          row.data['normalized_measurement_unit'] as String?,
    );
  }

  Future<int> _upsertCatalogProduct({
    required String name,
    required int productFamilyId,
    required String? barcode,
    required double packageQuantityAmount,
    required String packageQuantityUnit,
    required String normalizedMeasurementUnit,
    required bool isActive,
    required bool overwriteExisting,
    int? existingCatalogProductId,
  }) async {
    final identityKey = _buildCatalogProductIdentityKey(
      productFamilyId: productFamilyId,
      name: name,
      quantity: packageQuantityAmount,
      unitType: packageQuantityUnit,
      barcode: barcode,
    );

    if (existingCatalogProductId != null) {
      final conflicting = await dao.db.customSelect(
        'SELECT id FROM catalog_product WHERE identity_key = ? AND id != ? LIMIT 1;',
        variables: [
          Variable.withString(identityKey),
          Variable.withInt(existingCatalogProductId),
        ],
      ).getSingleOrNull();
      if (conflicting != null) {
        throw StateError(
          'Catalog product identity conflict for key $identityKey',
        );
      }
    }

    final existing = existingCatalogProductId != null
        ? await dao.db.customSelect(
            'SELECT id FROM catalog_product WHERE id = ? LIMIT 1;',
            variables: [Variable.withInt(existingCatalogProductId)],
          ).getSingleOrNull()
        : await dao.db.customSelect(
            'SELECT id FROM catalog_product WHERE identity_key = ? LIMIT 1;',
            variables: [Variable.withString(identityKey)],
          ).getSingleOrNull();

    if (existing != null) {
      final catalogProductId = existing.read<int>('id');
      if (!overwriteExisting) return catalogProductId;
      await dao.db.customStatement(
        '''
        UPDATE catalog_product
        SET nom = ?, actiu = ?, product_family_id = ?, barcode = ?,
            package_quantity_amount = ?, package_quantity_unit = ?,
            normalized_measurement_unit = ?, identity_key = ?
        WHERE id = ?;
        ''',
        [
          name.trim(),
          isActive ? 1 : 0,
          productFamilyId,
          barcode?.trim().isEmpty == true ? null : barcode?.trim(),
          packageQuantityAmount,
          packageQuantityUnit,
          normalizedMeasurementUnit,
          identityKey,
          catalogProductId,
        ],
      );
      return catalogProductId;
    }

    await dao.db.customStatement(
      '''
      INSERT INTO catalog_product (
        nom, actiu, product_family_id, barcode,
        package_quantity_amount, package_quantity_unit,
        normalized_measurement_unit, identity_key
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
      ''',
      [
        name.trim(),
        isActive ? 1 : 0,
        productFamilyId,
        barcode?.trim().isEmpty == true ? null : barcode?.trim(),
        packageQuantityAmount,
        packageQuantityUnit,
        normalizedMeasurementUnit,
        identityKey,
      ],
    );
    final inserted = await dao.db
        .customSelect(
          'SELECT last_insert_rowid() AS id;',
        )
        .getSingle();
    return inserted.read<int>('id');
  }

  Future<int> _insertPriceRecord({
    required int catalogProductId,
    required int supermarketId,
    required double price,
    required DateTime observedAt,
    required bool isActive,
    int? externalObservationId,
  }) async {
    await dao.db.customStatement(
      '''
      INSERT INTO price_record (
        catalog_product_id, supermarket_id, price, observed_at, actiu,
        external_observation_id
      ) VALUES (?, ?, ?, ?, ?, ?);
      ''',
      [
        catalogProductId,
        supermarketId,
        price,
        observedAt.millisecondsSinceEpoch,
        isActive ? 1 : 0,
        externalObservationId,
      ],
    );
    final inserted = await dao.db
        .customSelect(
          'SELECT last_insert_rowid() AS id;',
        )
        .getSingle();
    return inserted.read<int>('id');
  }

  String _buildCatalogProductIdentityKey({
    required int productFamilyId,
    required String name,
    required double quantity,
    required String unitType,
    required String? barcode,
  }) {
    final normalizedBarcode = barcode?.trim() ?? '';
    if (normalizedBarcode.isNotEmpty) {
      return 'barcode:$normalizedBarcode';
    }

    return 'fallback:$productFamilyId|${normalizeFamilyKey(name)}|${quantity.toStringAsFixed(6)}|${normalizeUnitTypeForStorage(unitType)}';
  }

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async {
    return _getDerivedProductItems(
      productFamilyId: productFamilyId,
      supermarketId: supermarketId,
      onlyCurrentPrice: onlyCurrentPrice,
    );
  }

  @override
  Future<int> saveProductItem(ProductItem item) async {
    final normalizedUnitType = normalizeUnitTypeForStorage(item.unitType);
    final normalizedMeasurementUnit = item.normalizedMeasurementUnit ??
        normalizeUnitTypeForComparison(normalizedUnitType);
    final quantity = item.packageQuantityAmount ?? item.quantity;
    final barcode = item.barcode?.trim();

    if (item.id != null) {
      final existing = await _getPriceRecordById(item.id!);
      if (existing == null) {
        throw StateError('Price record not found: ${item.id}');
      }

      final nextCatalogProductId = await _upsertCatalogProduct(
        name: item.name,
        productFamilyId: item.productFamilyId,
        barcode: barcode,
        packageQuantityAmount: quantity,
        packageQuantityUnit: normalizedUnitType,
        normalizedMeasurementUnit: normalizedMeasurementUnit,
        isActive: existing.catalogIsActive,
        overwriteExisting: true,
        existingCatalogProductId: existing.catalogProductId,
      );

      await dao.db.customStatement(
        '''
        UPDATE price_record
        SET catalog_product_id = ?, supermarket_id = ?, price = ?, observed_at = ?,
            actiu = ?, external_observation_id = ?
        WHERE id = ?;
        ''',
        [
          nextCatalogProductId,
          item.supermarketId,
          item.price,
          item.dateAdded.millisecondsSinceEpoch,
          item.isActive ? 1 : 0,
          item.externalObservationId,
          item.id,
        ],
      );
      return item.id!;
    }

    final catalogProductId = await _upsertCatalogProduct(
      name: item.name,
      productFamilyId: item.productFamilyId,
      barcode: barcode,
      packageQuantityAmount: quantity,
      packageQuantityUnit: normalizedUnitType,
      normalizedMeasurementUnit: normalizedMeasurementUnit,
      isActive: item.isActive,
      overwriteExisting: item.isCurrentPrice,
    );

    var observedAt = item.dateAdded;
    if (!item.isCurrentPrice) {
      final latest = await _getLatestPriceRecord(
        catalogProductId: catalogProductId,
        supermarketId: item.supermarketId,
      );
      if (latest != null && !observedAt.isBefore(latest.observedAt)) {
        observedAt =
            latest.observedAt.subtract(const Duration(milliseconds: 1));
      }
    }

    return _insertPriceRecord(
      catalogProductId: catalogProductId,
      supermarketId: item.supermarketId,
      price: item.price,
      observedAt: observedAt,
      isActive: item.isActive,
      externalObservationId: item.externalObservationId,
    );
  }

  @override
  Future<int?> getLastUsedSupermarketId() async {
    final row = await dao.db
        .customSelect(
          'SELECT supermarket_id FROM price_record ORDER BY observed_at DESC, id DESC LIMIT 1;',
        )
        .getSingleOrNull();
    if (row == null) return null;
    return row.read<int>('supermarket_id');
  }

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
    final trimmedName = productName.trim();
    final storedUnitType = normalizeUnitTypeForStorage(unitType);
    final familyId = await _resolveProductFamilyIdByName(
      familyName,
      shoppingUnit: inferShoppingUnitFromUnitType(unitType),
      purchaseMode: purchaseMode ?? inferPurchaseModeFromUnitType(unitType),
    );

    final catalogProductId = await _upsertCatalogProduct(
      name: trimmedName,
      productFamilyId: familyId,
      barcode: barcode,
      packageQuantityAmount: quantity,
      packageQuantityUnit: storedUnitType,
      normalizedMeasurementUnit: normalizeUnitTypeForComparison(storedUnitType),
      isActive: true,
      overwriteExisting: true,
    );

    final latest = await _getLatestPriceRecord(
      catalogProductId: catalogProductId,
      supermarketId: supermarketId,
    );
    if (latest != null &&
        latest.isActive &&
        (latest.price - price).abs() < _priceEpsilon) {
      final existingQuantity = latest.packageQuantityAmount ?? quantity;
      final existingUnit = latest.packageQuantityUnit ?? storedUnitType;
      if ((existingQuantity - quantity).abs() < _priceEpsilon &&
          normalizeUnitTypeForComparison(existingUnit) ==
              normalizeUnitTypeForComparison(storedUnitType)) {
        return latest.id;
      }
    }

    return _insertPriceRecord(
      catalogProductId: catalogProductId,
      supermarketId: supermarketId,
      price: price,
      observedAt: DateTime.now(),
      isActive: true,
    );
  }

  @override
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
    String barcode,
  ) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return const [];

    final items = await _getDerivedProductItems(
      onlyCurrentPrice: true,
      barcode: normalized,
    );
    final activeItems = items.where((item) => item.isActive).toList();
    if (activeItems.isEmpty) return const [];

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

    final sortedItems = [...activeItems]..sort((a, b) {
        final byCurrent =
            (b.isCurrentPrice ? 1 : 0) - (a.isCurrentPrice ? 1 : 0);
        if (byCurrent != 0) return byCurrent;

        final byDate = b.dateAdded.compareTo(a.dateAdded);
        if (byDate != 0) return byDate;

        final byUnit = a.pricePerQuantity.compareTo(b.pricePerQuantity);
        if (byUnit != 0) return byUnit;

        return a.price.compareTo(b.price);
      });

    return sortedItems
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

    final familyId = await _resolveProductFamilyIdByName(
      familyName,
      shoppingUnit: inferShoppingUnitFromUnitType(unitType),
      purchaseMode: inferPurchaseModeFromUnitType(unitType),
    );
    final unit = normalizeUnitTypeForStorage(unitType);
    final catalogProductId = await _upsertCatalogProduct(
      name: productName.trim(),
      productFamilyId: familyId,
      barcode: normalizedBarcode,
      packageQuantityAmount: quantity,
      packageQuantityUnit: unit,
      normalizedMeasurementUnit: normalizeUnitTypeForComparison(unit),
      isActive: true,
      overwriteExisting: true,
    );

    final latest = await _getLatestPriceRecord(
      catalogProductId: catalogProductId,
      supermarketId: supermarketId,
    );

    if (latest != null &&
        latest.isActive &&
        (latest.price - price).abs() < _priceEpsilon &&
        ((latest.packageQuantityAmount ?? quantity) - quantity).abs() <
            _priceEpsilon &&
        normalizeUnitTypeForComparison(latest.packageQuantityUnit ?? unit) ==
            normalizeUnitTypeForComparison(unit)) {
      return const ScannedPriceRegistrationResult(
        created: false,
        message:
            'Price already current in this supermarket. No new price record created.',
      );
    }

    await _insertPriceRecord(
      catalogProductId: catalogProductId,
      supermarketId: supermarketId,
      price: price,
      observedAt: DateTime.now(),
      isActive: true,
    );

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
            localPriceRecordId: row.localPriceRecordId,
          ),
        )
        .toList();
  }

  @override
  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  ) async {
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
        localPriceRecordId: existing != null
            ? Value(existing.localPriceRecordId)
            : Value(observation.localPriceRecordId),
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
    final current = ExternalObservationReviewStatusCodec.fromStorageValue(
      row.reviewStatus,
    );
    if (!canTransitionReviewStatus(from: current, to: newStatus)) {
      throw StateError(
        'Invalid review status transition: $current -> $newStatus',
      );
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
        localPriceRecordId: Value(row.localPriceRecordId),
      ),
    );
  }

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
  }) async {
    return dao.db.transaction(() async {
      final observation = await dao.getExternalPriceObservationById(
        observationId,
      );
      if (observation == null) {
        throw StateError('External observation not found: $observationId');
      }

      if (observation.localPriceRecordId != null) {
        throw StateError(
          'Observation $observationId is already confirmed '
          'with local price record ${observation.localPriceRecordId}',
        );
      }

      final currentStatus =
          ExternalObservationReviewStatusCodec.fromStorageValue(
        observation.reviewStatus,
      );
      if (!canTransitionReviewStatus(
        from: currentStatus,
        to: ExternalObservationReviewStatus.acceptedForComparison,
      )) {
        throw StateError(
          'Invalid review status transition: $currentStatus -> ${ExternalObservationReviewStatus.acceptedForComparison}',
        );
      }

      final mapping = await dao.getExternalStoreMappingByExternalId(
        observation.externalStoreId,
      );
      if (mapping == null) {
        throw StateError(
          'Missing external store mapping for ${observation.externalStoreId}',
        );
      }

      final familyId = await resolveProductFamilyIdByName(
        observation.familyName,
      );
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
          normalizedMeasurementUnit: normalizeUnitTypeForComparison(
            observation.unitType,
          ),
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
          localProductItemId: Value(observation.localProductItemId),
          localPriceRecordId: Value(productItemId),
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
      ShoppingListEntry(productFamilyId: productFamilyId, quantity: quantity),
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
        ...acceptedExternalItems.where((i) => i.productFamilyId > 0),
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

class _PriceRecordSnapshot {
  const _PriceRecordSnapshot({
    required this.id,
    required this.catalogProductId,
    required this.supermarketId,
    required this.price,
    required this.observedAt,
    required this.isActive,
    required this.catalogIsActive,
    required this.externalObservationId,
    required this.name,
    required this.productFamilyId,
    required this.barcode,
    required this.packageQuantityAmount,
    required this.packageQuantityUnit,
    required this.normalizedMeasurementUnit,
  });

  final int id;
  final int catalogProductId;
  final int supermarketId;
  final double price;
  final DateTime observedAt;
  final bool isActive;
  final bool catalogIsActive;
  final int? externalObservationId;
  final String name;
  final int productFamilyId;
  final String? barcode;
  final double? packageQuantityAmount;
  final String? packageQuantityUnit;
  final String? normalizedMeasurementUnit;
}
