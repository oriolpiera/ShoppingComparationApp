import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/normalization/catalog_product_identity.dart';
import '../../../../core/normalization/unit_normalization.dart';
import '../../domain/entities/barcode_match_result.dart';
import '../../domain/entities/catalog_product.dart';
import '../../domain/entities/price_record.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/entities/scanned_price_registration_result.dart';

class DriftPriceRecordRepository {
  final PersistenceDao dao;
  static const double _priceEpsilon = 1e-9;

  DriftPriceRecordRepository(this.dao);

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
        observedAt = latest.observedAt.subtract(
          const Duration(milliseconds: 1),
        );
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

  Future<int?> getLastUsedSupermarketId() async {
    final row = await dao.db
        .customSelect(
          'SELECT supermarket_id FROM price_record ORDER BY observed_at DESC, id DESC LIMIT 1;',
        )
        .getSingleOrNull();
    if (row == null) return null;
    return row.read<int>('supermarket_id');
  }

  Future<int> saveQuickProductItem({
    required String productName,
    required int familyId,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? purchaseMode,
    String? barcode,
  }) async {
    final trimmedName = productName.trim();
    final storedUnitType = normalizeUnitTypeForStorage(unitType);

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

  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
    String barcode,
  ) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return const [];

    final rows = await dao.db.customSelect(
      '''
      SELECT
        cp.id AS catalog_product_id,
        cp.nom AS product_name,
        cp.actiu AS catalog_active,
        cp.product_family_id,
        cp.barcode,
        cp.package_quantity_amount,
        cp.package_quantity_unit,
        cp.normalized_measurement_unit,
        cp.identity_key,
        pr.id AS price_record_id,
        pr.supermarket_id,
        pr.price,
        pr.observed_at,
        pr.actiu AS price_record_active,
        pr.external_observation_id,
        pf.nom AS family_name,
        s.nom AS supermarket_name
      FROM price_record pr
      JOIN catalog_product cp ON cp.id = pr.catalog_product_id
      JOIN product_family pf ON pf.id = cp.product_family_id
      JOIN supermarket s ON s.id = pr.supermarket_id
      WHERE cp.barcode = ?
        AND cp.actiu = 1
        AND pr.actiu = 1
        AND ${_isCurrentPriceSql(alias: 'pr')}
      ORDER BY pr.observed_at DESC, pr.id DESC;
      ''',
      variables: [Variable.withString(normalized)],
    ).get();

    if (rows.isEmpty) return const [];

    final matches = rows
        .map(
          (row) => BarcodeMatchResult(
            catalogProduct: CatalogProduct(
              id: row.read<int>('catalog_product_id'),
              name: row.read<String>('product_name'),
              isActive: (row.data['catalog_active'] as int? ?? 0) == 1,
              productFamilyId: row.read<int>('product_family_id'),
              barcode: row.data['barcode'] as String?,
              packageQuantityAmount:
                  (row.data['package_quantity_amount'] as num?)?.toDouble(),
              packageQuantityUnit: row.data['package_quantity_unit'] as String?,
              normalizedMeasurementUnit:
                  row.data['normalized_measurement_unit'] as String?,
              identityKey: row.read<String>('identity_key'),
            ),
            priceRecord: PriceRecord(
              id: row.read<int>('price_record_id'),
              catalogProductId: row.read<int>('catalog_product_id'),
              supermarketId: row.read<int>('supermarket_id'),
              price: row.read<double>('price'),
              observedAt: DateTime.fromMillisecondsSinceEpoch(
                (row.data['observed_at'] as int?) ?? 0,
              ),
              isActive: (row.data['price_record_active'] as int? ?? 0) == 1,
              externalObservationId:
                  row.data['external_observation_id'] as int?,
            ),
            familyName: row.read<String>('family_name'),
            supermarketName: row.read<String>('supermarket_name'),
          ),
        )
        .toList();

    matches.sort((a, b) {
      final byDate =
          b.priceRecord.observedAt.compareTo(a.priceRecord.observedAt);
      if (byDate != 0) return byDate;

      final byUnit = a.pricePerQuantity.compareTo(b.pricePerQuantity);
      if (byUnit != 0) return byUnit;

      return a.priceRecord.price.compareTo(b.priceRecord.price);
    });

    return matches;
  }

  Future<ScannedPriceRegistrationResult> registerScannedPrice({
    required String barcode,
    required String productName,
    required int familyId,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
  }) async {
    final normalizedBarcode = barcode.trim();
    final trimmedProductName = productName.trim();
    if (normalizedBarcode.isEmpty) {
      return const ScannedPriceRegistrationResult(
        created: false,
        message: 'Barcode is required.',
      );
    }

    final unit = normalizeUnitTypeForStorage(unitType);
    final normalizedMeasurementUnit = normalizeUnitTypeForComparison(unit);
    final identityKey = buildCatalogProductIdentityKey(
      productFamilyId: familyId,
      name: trimmedProductName,
      quantity: quantity,
      unitType: unit,
      barcode: normalizedBarcode,
    );
    final catalogProductId = await _upsertCatalogProduct(
      name: trimmedProductName,
      productFamilyId: familyId,
      barcode: normalizedBarcode,
      packageQuantityAmount: quantity,
      packageQuantityUnit: unit,
      normalizedMeasurementUnit: normalizedMeasurementUnit,
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
      return ScannedPriceRegistrationResult(
        created: false,
        catalogProduct: CatalogProduct(
          id: latest.catalogProductId,
          name: latest.name,
          isActive: latest.catalogIsActive,
          productFamilyId: latest.productFamilyId,
          barcode: latest.barcode,
          packageQuantityAmount: latest.packageQuantityAmount,
          packageQuantityUnit: latest.packageQuantityUnit,
          normalizedMeasurementUnit: latest.normalizedMeasurementUnit,
          identityKey: latest.identityKey,
        ),
        priceRecord: PriceRecord(
          id: latest.id,
          catalogProductId: latest.catalogProductId,
          supermarketId: latest.supermarketId,
          price: latest.price,
          observedAt: latest.observedAt,
          isActive: latest.isActive,
          externalObservationId: latest.externalObservationId,
        ),
        message:
            'Price already current in this supermarket. No new price record created.',
      );
    }

    final observedAt = DateTime.now();
    final priceRecordId = await _insertPriceRecord(
      catalogProductId: catalogProductId,
      supermarketId: supermarketId,
      price: price,
      observedAt: observedAt,
      isActive: true,
    );

    return ScannedPriceRegistrationResult(
      created: true,
      catalogProduct: CatalogProduct(
        id: catalogProductId,
        name: trimmedProductName,
        isActive: true,
        productFamilyId: familyId,
        barcode: normalizedBarcode,
        packageQuantityAmount: quantity,
        packageQuantityUnit: unit,
        normalizedMeasurementUnit: normalizedMeasurementUnit,
        identityKey: identityKey,
      ),
      priceRecord: PriceRecord(
        id: priceRecordId,
        catalogProductId: catalogProductId,
        supermarketId: supermarketId,
        price: price,
        observedAt: observedAt,
        isActive: true,
      ),
      message: 'New current price registered.',
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

    final rows = await dao.db.customSelect('''
      SELECT
        pr.id AS price_record_id,
        cp.id AS catalog_product_id,
        cp.nom AS product_name,
        cp.actiu AS catalog_active,
        cp.product_family_id,
        cp.barcode,
        cp.package_quantity_amount,
        cp.package_quantity_unit,
        cp.normalized_measurement_unit,
        cp.identity_key,
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
      ''', variables: variables).get();

    return rows.map((row) {
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
    }).toList();
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
        cp.normalized_measurement_unit,
        cp.identity_key
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
      identityKey: row.read<String>('identity_key'),
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
        cp.normalized_measurement_unit,
        cp.identity_key
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
      identityKey: row.read<String>('identity_key'),
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
    final identityKey = buildCatalogProductIdentityKey(
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
            'SELECT id, actiu FROM catalog_product WHERE identity_key = ? LIMIT 1;',
            variables: [Variable.withString(identityKey)],
          ).getSingleOrNull();

    if (existing != null) {
      final catalogProductId = existing.read<int>('id');
      if (!overwriteExisting) return catalogProductId;
      final nextCatalogIsActive =
          (existing.data['actiu'] as int? ?? 0) == 1 || isActive;
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
          nextCatalogIsActive ? 1 : 0,
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
        .customSelect('SELECT last_insert_rowid() AS id;')
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
        .customSelect('SELECT last_insert_rowid() AS id;')
        .getSingle();
    return inserted.read<int>('id');
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
    required this.identityKey,
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
  final String identityKey;
}
