import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates schema v3 to v4 adding OpenPrices tables and link column',
      () async {
    final file =
        File('${Directory.systemTemp.path}/drift_migration_v4_test.sqlite');
    if (file.existsSync()) file.deleteSync();

    AppDriftDatabase? db;
    addTearDown(() async {
      await db?.close();
      if (file.existsSync()) file.deleteSync();
    });

    final setupDb = sqlite3.open(file.path);
    setupDb.execute('''
      CREATE TABLE product_family (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        actiu INTEGER NOT NULL DEFAULT 1,
        shopping_unit TEXT,
        purchase_mode TEXT
      );
    ''');
    setupDb.execute('''
      CREATE TABLE supermarket (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        adreca TEXT NULL,
        actiu INTEGER NOT NULL DEFAULT 1
      );
    ''');
    setupDb.execute('''
      CREATE TABLE product_item (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        actiu INTEGER NOT NULL DEFAULT 1,
        product_family_id INTEGER NOT NULL,
        supermarket_id INTEGER NOT NULL,
        price REAL NOT NULL,
        quantity REAL NOT NULL,
        unit_type TEXT NOT NULL,
        price_per_quantity REAL NOT NULL,
        package_quantity_amount REAL,
        package_quantity_unit TEXT,
        normalized_measurement_unit TEXT,
        date_added INTEGER NOT NULL,
        is_current_price INTEGER NOT NULL DEFAULT 1,
        barcode TEXT NULL
      );
    ''');
    setupDb.execute('''
      CREATE TABLE shopping_list (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        product_family_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        product_item_id INTEGER NULL
      );
    ''');
    setupDb.execute('PRAGMA user_version = 3;');
    setupDb.dispose();

    db = AppDriftDatabase.forTesting(NativeDatabase(file));

    final itemColumns =
        await db.customSelect('PRAGMA table_info(product_item);').get();
    expect(
        itemColumns.any((row) => row.data['name'] == 'external_observation_id'),
        isTrue);

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table';")
        .get();
    final tableNames = tables.map((t) => t.data['name']).toSet();
    expect(tableNames, contains('external_store_mapping'));
    expect(tableNames, contains('external_price_observation'));

    final openPricesIndexes = await db
        .customSelect("PRAGMA index_list('external_price_observation');")
        .get();
    final hasUniqueOpenPricesIndex = openPricesIndexes.any(
      (row) =>
          (row.data['name']?.toString() ?? '').contains('open_prices_id') &&
          row.data['unique'] == 1,
    );
    expect(hasUniqueOpenPricesIndex, isTrue);
  });
}
