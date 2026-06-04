import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates schema v4 shopping semantics to canonical values', () async {
    final file =
        File('${Directory.systemTemp.path}/drift_migration_v5_test.sqlite');
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
      "INSERT INTO product_family (id, nom, actiu, shopping_unit, purchase_mode) VALUES (1, 'Eggs', 1, 'unit', 'piece');",
    );
    setupDb.execute(
      "INSERT INTO product_family (id, nom, actiu, shopping_unit, purchase_mode) VALUES (2, 'Tomatoes', 1, 'kg', 'fresh');",
    );
    setupDb.execute(
      "INSERT INTO product_family (id, nom, actiu, shopping_unit, purchase_mode) VALUES (3, 'Milk', 1, 'L', 'packaged');",
    );
    setupDb.execute('PRAGMA user_version = 4;');
    setupDb.close();

    db = AppDriftDatabase.forTesting(NativeDatabase(file));

    final rows = await db
        .customSelect(
          'SELECT id, shopping_unit, purchase_mode FROM product_family ORDER BY id;',
        )
        .get();

    expect(rows[0].data['shopping_unit'], 'piece');
    expect(rows[0].data['purchase_mode'], 'piece');
    expect(rows[1].data['shopping_unit'], 'kilogram');
    expect(rows[1].data['purchase_mode'], 'weighted');
    expect(rows[2].data['shopping_unit'], 'liter');
    expect(rows[2].data['purchase_mode'], 'packaged');
  });
}
