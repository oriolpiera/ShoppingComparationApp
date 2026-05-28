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
  RealColumn get quantity => real()();
  IntColumn get productItemId => integer().references(ProductItemTable, #id)();
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

  @override
  int get schemaVersion => 1;
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
