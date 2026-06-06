import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../normalization/catalog_product_identity.dart';
import '../normalization/unit_normalization.dart';

part 'drift_database.g.dart';

class SupermarketTable extends Table {
  @override
  String get tableName => 'supermarket';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  TextColumn get adreca => text().nullable()();
  BoolColumn get actiu => boolean().withDefault(const Constant(true))();
}

class ProductFamilyTable extends Table {
  @override
  String get tableName => 'product_family';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  BoolColumn get actiu => boolean().withDefault(const Constant(true))();
  TextColumn get shoppingUnit => text().nullable()();
  TextColumn get purchaseMode => text().nullable()();
}

class ProductItemTable extends Table {
  @override
  String get tableName => 'product_item';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  BoolColumn get actiu => boolean().withDefault(const Constant(true))();

  IntColumn get productFamilyId =>
      integer().references(ProductFamilyTable, #id)();
  IntColumn get supermarketId => integer().references(SupermarketTable, #id)();

  RealColumn get price => real()();
  RealColumn get quantity => real()();
  TextColumn get unitType => text()();
  RealColumn get pricePerQuantity => real()();
  RealColumn get packageQuantityAmount => real().nullable()();
  TextColumn get packageQuantityUnit => text().nullable()();
  TextColumn get normalizedMeasurementUnit => text().nullable()();

  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isCurrentPrice =>
      boolean().withDefault(const Constant(true))();
  TextColumn get barcode => text().nullable()();
  IntColumn get externalObservationId => integer().nullable()();
}

class CatalogProductTable extends Table {
  @override
  String get tableName => 'catalog_product';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  BoolColumn get actiu => boolean().withDefault(const Constant(true))();
  IntColumn get productFamilyId =>
      integer().references(ProductFamilyTable, #id)();
  TextColumn get barcode => text().nullable()();
  RealColumn get packageQuantityAmount => real().nullable()();
  TextColumn get packageQuantityUnit => text().nullable()();
  TextColumn get normalizedMeasurementUnit => text().nullable()();
  TextColumn get identityKey => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {identityKey},
      ];
}

class PriceRecordTable extends Table {
  @override
  String get tableName => 'price_record';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get catalogProductId =>
      integer().references(CatalogProductTable, #id)();
  IntColumn get supermarketId => integer().references(SupermarketTable, #id)();
  RealColumn get price => real()();
  DateTimeColumn get observedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get actiu => boolean().withDefault(const Constant(true))();
  IntColumn get externalObservationId => integer().nullable()();
}

class ExternalStoreMappingTable extends Table {
  @override
  String get tableName => 'external_store_mapping';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalStoreId => text()();
  TextColumn get externalStoreName => text()();
  IntColumn get supermarketId => integer().references(SupermarketTable, #id)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {externalStoreId},
      ];
}

class ExternalPriceObservationTable extends Table {
  @override
  String get tableName => 'external_price_observation';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get openPricesId => text()();
  TextColumn get productName => text()();
  TextColumn get familyName => text()();
  TextColumn get externalStoreId => text()();
  TextColumn get externalStoreName => text()();
  RealColumn get price => real()();
  RealColumn get quantity => real()();
  TextColumn get unitType => text()();
  RealColumn get pricePerQuantity => real()();
  DateTimeColumn get observedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reviewStatus =>
      text().withDefault(const Constant('unreviewed'))();
  IntColumn get localProductItemId => integer().nullable()();
  IntColumn get localPriceRecordId => integer().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {openPricesId},
      ];
}

class ShoppingListTable extends Table {
  @override
  String get tableName => 'shopping_list';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get productFamilyId =>
      integer().references(ProductFamilyTable, #id)();
  IntColumn get quantity => integer()();
  IntColumn get productItemId =>
      integer().nullable().references(ProductItemTable, #id)();
}

@DriftDatabase(
  tables: [
    SupermarketTable,
    ProductFamilyTable,
    ProductItemTable,
    CatalogProductTable,
    PriceRecordTable,
    ShoppingListTable,
    ExternalStoreMappingTable,
    ExternalPriceObservationTable,
  ],
)
class AppDriftDatabase extends _$AppDriftDatabase {
  AppDriftDatabase() : super(_openConnection());
  AppDriftDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement('''
              CREATE TABLE shopping_list_v2 (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                product_family_id INTEGER NOT NULL REFERENCES product_family (id),
                quantity INTEGER NOT NULL,
                product_item_id INTEGER NULL REFERENCES product_item (id)
              );
            ''');
            await customStatement('''
              INSERT INTO shopping_list_v2 (id, product_family_id, quantity, product_item_id)
              SELECT id, product_family_id, CAST(quantity AS INTEGER), product_item_id
              FROM shopping_list;
            ''');
            await customStatement('DROP TABLE shopping_list;');
            await customStatement(
                'ALTER TABLE shopping_list_v2 RENAME TO shopping_list;');
          }

          if (from < 3) {
            await customStatement(
              'ALTER TABLE product_family ADD COLUMN shopping_unit TEXT;',
            );
            await customStatement(
              'ALTER TABLE product_family ADD COLUMN purchase_mode TEXT;',
            );
            await customStatement(
              'ALTER TABLE product_item ADD COLUMN package_quantity_amount REAL;',
            );
            await customStatement(
              'ALTER TABLE product_item ADD COLUMN package_quantity_unit TEXT;',
            );
            await customStatement(
              'ALTER TABLE product_item ADD COLUMN normalized_measurement_unit TEXT;',
            );
          }

          if (from < 4) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS external_price_observation (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                open_prices_id TEXT NOT NULL UNIQUE,
                product_name TEXT NOT NULL,
                family_name TEXT NOT NULL,
                external_store_id TEXT NOT NULL,
                external_store_name TEXT NOT NULL,
                price REAL NOT NULL,
                quantity REAL NOT NULL,
                unit_type TEXT NOT NULL,
                price_per_quantity REAL NOT NULL,
                observed_at INTEGER NOT NULL,
                review_status TEXT NOT NULL DEFAULT 'unreviewed',
                local_product_item_id INTEGER NULL REFERENCES product_item (id)
              );
            ''');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS external_store_mapping (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                external_store_id TEXT NOT NULL UNIQUE,
                external_store_name TEXT NOT NULL,
                supermarket_id INTEGER NOT NULL REFERENCES supermarket (id)
              );
            ''');
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_external_price_observation_open_prices_id ON external_price_observation(open_prices_id);',
            );

            try {
              await customStatement(
                'ALTER TABLE product_item ADD COLUMN external_observation_id INTEGER NULL REFERENCES external_price_observation(id);',
              );
            } catch (_) {
              // Column may already exist from fresh-schema creation or prior run.
            }
          }

          if (from < 5) {
            await customStatement('''
              UPDATE product_family
              SET shopping_unit = CASE lower(trim(coalesce(shopping_unit, '')))
                WHEN 'kg' THEN 'kilogram'
                WHEN 'kilogram' THEN 'kilogram'
                WHEN 'l' THEN 'liter'
                WHEN 'liter' THEN 'liter'
                WHEN 'unit' THEN 'piece'
                WHEN 'piece' THEN 'piece'
                ELSE shopping_unit
              END
              WHERE shopping_unit IS NOT NULL;
            ''');
            await customStatement('''
              UPDATE product_family
              SET purchase_mode = CASE lower(trim(coalesce(purchase_mode, '')))
                WHEN 'fresh' THEN 'weighted'
                WHEN 'weighted' THEN 'weighted'
                WHEN 'packaged' THEN 'packaged'
                WHEN 'piece' THEN 'piece'
                ELSE purchase_mode
              END
              WHERE purchase_mode IS NOT NULL;
            ''');
          }

          if (from < 6) {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS catalog_product (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                nom TEXT NOT NULL,
                actiu INTEGER NOT NULL DEFAULT 1,
                product_family_id INTEGER NOT NULL REFERENCES product_family (id),
                barcode TEXT NULL,
                package_quantity_amount REAL NULL,
                package_quantity_unit TEXT NULL,
                normalized_measurement_unit TEXT NULL,
                identity_key TEXT NOT NULL UNIQUE
              );
            ''');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS price_record (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                catalog_product_id INTEGER NOT NULL REFERENCES catalog_product (id),
                supermarket_id INTEGER NOT NULL REFERENCES supermarket (id),
                price REAL NOT NULL,
                observed_at INTEGER NOT NULL,
                actiu INTEGER NOT NULL DEFAULT 1,
                external_observation_id INTEGER NULL
              );
            ''');

            try {
              await customStatement(
                'ALTER TABLE external_price_observation ADD COLUMN local_price_record_id INTEGER NULL;',
              );
            } catch (_) {
              // Column may already exist.
            }

            final oldRows = await customSelect('''
              SELECT id, nom, actiu, product_family_id, supermarket_id, price,
                     quantity, unit_type, package_quantity_amount,
                     package_quantity_unit, normalized_measurement_unit,
                     date_added, barcode, external_observation_id
              FROM product_item
              ORDER BY id ASC;
            ''').get();

            final catalogIdByIdentity = <String, int>{};
            final priceRecordIdByLegacyItemId = <int, int>{};

            for (final row in oldRows) {
              final legacyId = row.read<int>('id');
              final name = row.read<String>('nom');
              final isActive = (row.data['actiu'] as int? ?? 0) == 1;
              final familyId = row.read<int>('product_family_id');
              final supermarketId = row.read<int>('supermarket_id');
              final price = row.read<double>('price');
              final quantity =
                  (row.data['package_quantity_amount'] as num?)?.toDouble() ??
                      row.read<double>('quantity');
              final unitType = normalizeUnitTypeForStorage(
                (row.data['package_quantity_unit'] as String?) ??
                    row.read<String>('unit_type'),
              );
              final normalizedMeasurementUnit =
                  (row.data['normalized_measurement_unit'] as String?) ??
                      normalizeUnitTypeForComparison(unitType);
              final barcode = (row.data['barcode'] as String?)?.trim();
              final externalObservationId =
                  (row.data['external_observation_id'] as int?);
              final observedAt = DateTime.fromMillisecondsSinceEpoch(
                (row.data['date_added'] as int?) ?? 0,
              );

              final identityKey = buildCatalogProductIdentityKey(
                productFamilyId: familyId,
                name: name,
                quantity: quantity,
                unitType: unitType,
                barcode: barcode,
              );

              var catalogId = catalogIdByIdentity[identityKey];
              if (catalogId == null) {
                final existingCatalog = await customSelect(
                  'SELECT id, actiu FROM catalog_product WHERE identity_key = ? LIMIT 1;',
                  variables: [Variable.withString(identityKey)],
                ).getSingleOrNull();
                if (existingCatalog != null) {
                  catalogId = existingCatalog.read<int>('id');
                  final catalogIsActive =
                      (existingCatalog.data['actiu'] as int? ?? 0) == 1;
                  if (isActive && !catalogIsActive) {
                    await customStatement(
                      'UPDATE catalog_product SET actiu = 1 WHERE id = ?;',
                      [catalogId],
                    );
                  }
                } else {
                  await customStatement(
                    '''
                    INSERT INTO catalog_product (
                      nom, actiu, product_family_id, barcode,
                      package_quantity_amount, package_quantity_unit,
                      normalized_measurement_unit, identity_key
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
                    ''',
                    [
                      name,
                      isActive ? 1 : 0,
                      familyId,
                      (barcode == null || barcode.isEmpty) ? null : barcode,
                      quantity,
                      unitType,
                      normalizedMeasurementUnit,
                      identityKey,
                    ],
                  );
                  final insertedCatalog = await customSelect(
                    'SELECT last_insert_rowid() AS id;',
                  ).getSingle();
                  catalogId = insertedCatalog.read<int>('id');
                }
                catalogIdByIdentity[identityKey] = catalogId;
              } else if (isActive) {
                await customStatement(
                  'UPDATE catalog_product SET actiu = 1 WHERE id = ?;',
                  [catalogId],
                );
              }

              await customStatement(
                '''
                INSERT INTO price_record (
                  catalog_product_id, supermarket_id, price, observed_at, actiu,
                  external_observation_id
                ) VALUES (?, ?, ?, ?, ?, ?);
                ''',
                [
                  catalogId,
                  supermarketId,
                  price,
                  observedAt.millisecondsSinceEpoch,
                  isActive ? 1 : 0,
                  externalObservationId,
                ],
              );
              final insertedPriceRecord = await customSelect(
                'SELECT last_insert_rowid() AS id;',
              ).getSingle();
              priceRecordIdByLegacyItemId[legacyId] =
                  insertedPriceRecord.read<int>('id');
            }

            final linkedObservations = await customSelect('''
              SELECT id, local_product_item_id
              FROM external_price_observation
              WHERE local_product_item_id IS NOT NULL;
            ''').get();

            for (final row in linkedObservations) {
              final legacyItemId = row.read<int>('local_product_item_id');
              final priceRecordId = priceRecordIdByLegacyItemId[legacyItemId];
              if (priceRecordId == null) continue;

              await customStatement(
                '''
                UPDATE external_price_observation
                SET local_price_record_id = ?
                WHERE id = ?;
                ''',
                [priceRecordId, row.read<int>('id')],
              );
            }
          }
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'shopping_comparation',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
