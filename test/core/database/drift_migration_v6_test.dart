import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates v5 product history without hiding active catalog products',
      () async {
    final file =
        File('${Directory.systemTemp.path}/drift_migration_v6_test.sqlite');
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
        barcode TEXT NULL,
        external_observation_id INTEGER NULL
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
    setupDb.execute('''
      CREATE TABLE external_price_observation (
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
        local_product_item_id INTEGER NULL
      );
    ''');
    setupDb.execute('''
      CREATE TABLE external_store_mapping (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        external_store_id TEXT NOT NULL UNIQUE,
        external_store_name TEXT NOT NULL,
        supermarket_id INTEGER NOT NULL
      );
    ''');
    setupDb.execute(
      "INSERT INTO product_family (id, nom, actiu, shopping_unit, purchase_mode) VALUES (1, 'Peanuts', 1, 'kilogram', 'packaged');",
    );
    setupDb.execute(
      "INSERT INTO supermarket (id, nom, adreca, actiu) VALUES (1, 'Market', NULL, 1);",
    );
    setupDb.execute('''
      INSERT INTO product_item (
        id, nom, actiu, product_family_id, supermarket_id, price, quantity,
        unit_type, price_per_quantity, package_quantity_amount,
        package_quantity_unit, normalized_measurement_unit, date_added,
        is_current_price, barcode, external_observation_id
      ) VALUES (
        1, 'Peanuts', 0, 1, 1, 1.50, 1.0,
        'kg', 1.50, 1.0,
        'kg', 'kg', 1735689600000,
        0, 'PEANUTS-1', NULL
      );
    ''');
    setupDb.execute('''
      INSERT INTO product_item (
        id, nom, actiu, product_family_id, supermarket_id, price, quantity,
        unit_type, price_per_quantity, package_quantity_amount,
        package_quantity_unit, normalized_measurement_unit, date_added,
        is_current_price, barcode, external_observation_id
      ) VALUES (
        2, 'Peanuts', 1, 1, 1, 1.40, 1.0,
        'kg', 1.40, 1.0,
        'kg', 'kg', 1738368000000,
        1, 'PEANUTS-1', NULL
      );
    ''');
    setupDb.execute('PRAGMA user_version = 5;');
    setupDb.close();

    db = AppDriftDatabase.forTesting(NativeDatabase(file));

    final catalogRows = await db.customSelect('''
      SELECT actiu
      FROM catalog_product
      WHERE barcode = 'PEANUTS-1'
      LIMIT 1;
    ''').get();

    final derivedRows = await db.customSelect('''
      SELECT cp.actiu AS catalog_actiu, pr.actiu AS price_actiu
      FROM catalog_product cp
      JOIN price_record pr ON pr.catalog_product_id = cp.id
      WHERE cp.barcode = 'PEANUTS-1'
      ORDER BY pr.observed_at DESC, pr.id DESC
      LIMIT 1;
    ''').getSingle();

    expect(catalogRows.single.data['actiu'], 1);
    expect(derivedRows.data['catalog_actiu'], 1);
    expect(derivedRows.data['price_actiu'], 1);
  });
}
