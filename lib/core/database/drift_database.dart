import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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
    ShoppingListTable,
  ],
)
class AppDriftDatabase extends _$AppDriftDatabase {
  AppDriftDatabase() : super(_openConnection());
  AppDriftDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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
