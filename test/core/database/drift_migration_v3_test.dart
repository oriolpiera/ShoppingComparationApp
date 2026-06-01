import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('migrates schema v2 to v3 adding shopping semantics columns', () async {
    final file =
        File('${Directory.systemTemp.path}/drift_migration_v3_test.sqlite');
    if (file.existsSync()) {
      file.deleteSync();
    }

    final setupDb = sqlite3.open(file.path);
    setupDb.execute('''
      CREATE TABLE product_family (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        actiu INTEGER NOT NULL DEFAULT 1
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
    setupDb.execute(
        "INSERT INTO product_family (id, nom, actiu) VALUES (1, 'Milk', 1);");
    setupDb.execute('''
      INSERT INTO product_item (
        id, nom, actiu, product_family_id, supermarket_id, price, quantity,
        unit_type, price_per_quantity, date_added, is_current_price, barcode
      ) VALUES (1, 'Whole milk', 1, 1, 1, 1.5, 1.0, 'l', 1.5, 0, 1, 'B1');
    ''');
    setupDb.execute('PRAGMA user_version = 2;');
    setupDb.dispose();

    final db = AppDriftDatabase.forTesting(NativeDatabase(file));

    final familyColumns =
        await db.customSelect('PRAGMA table_info(product_family);').get();
    final itemColumns =
        await db.customSelect('PRAGMA table_info(product_item);').get();

    expect(
      familyColumns.any((row) => row.data['name'] == 'shopping_unit'),
      isTrue,
    );
    expect(
      familyColumns.any((row) => row.data['name'] == 'purchase_mode'),
      isTrue,
    );
    expect(
      itemColumns.any((row) => row.data['name'] == 'package_quantity_amount'),
      isTrue,
    );
    expect(
      itemColumns.any((row) => row.data['name'] == 'package_quantity_unit'),
      isTrue,
    );
    expect(
      itemColumns
          .any((row) => row.data['name'] == 'normalized_measurement_unit'),
      isTrue,
    );

    final family = await db
        .customSelect(
          'SELECT nom, shopping_unit, purchase_mode FROM product_family WHERE id = 1;',
        )
        .getSingle();
    expect(family.data['nom'], 'Milk');
    expect(family.data['shopping_unit'], isNull);
    expect(family.data['purchase_mode'], isNull);

    final item = await db.customSelect(
      '''
          SELECT nom, price, quantity, unit_type, price_per_quantity, barcode,
                 package_quantity_amount, package_quantity_unit, normalized_measurement_unit
          FROM product_item WHERE id = 1;
          ''',
    ).getSingle();
    expect(item.data['nom'], 'Whole milk');
    expect(item.data['price'], 1.5);
    expect(item.data['quantity'], 1.0);
    expect(item.data['unit_type'], 'l');
    expect(item.data['price_per_quantity'], 1.5);
    expect(item.data['barcode'], 'B1');
    expect(item.data['package_quantity_amount'], isNull);
    expect(item.data['package_quantity_unit'], isNull);
    expect(item.data['normalized_measurement_unit'], isNull);

    await db.close();
    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}
