import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:shopping_comparation_app/features/persistence/data/repositories/drift_persistence_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getTemporaryDirectory' ||
          call.method == 'getApplicationDocumentsDirectory') {
        return '/tmp';
      }
      return null;
    });
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  late AppDriftDatabase db;
  late DriftPersistenceRepository repository;

  setUp(() async {
    db = AppDriftDatabase();
    repository = DriftPersistenceRepository.fromDatabase(db);
    await db.customStatement('DELETE FROM shopping_list;');
    await db.customStatement('DELETE FROM price_record;');
    await db.customStatement('DELETE FROM catalog_product;');
    await db.customStatement('DELETE FROM product_item;');
    await db.customStatement('DELETE FROM product_family;');
    await db.customStatement('DELETE FROM supermarket;');
  });

  tearDown(() async {
    await db.close();
  });

  test('findCurrentActiveByBarcode returns only current and active matches',
      () async {
    final marketId = await repository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final familyId = await repository.saveProductFamily(
      const ProductFamily(name: 'Milk', isActive: true),
    );

    await repository.saveProductItem(
      ProductItem(
        name: 'Milk 1',
        productFamilyId: familyId,
        supermarketId: marketId,
        price: 1,
        quantity: 1,
        unitType: 'L',
        pricePerQuantity: 1,
        dateAdded: DateTime(2026, 1, 1),
        isCurrentPrice: true,
        isActive: true,
        barcode: 'X1',
      ),
    );
    await repository.saveProductItem(
      ProductItem(
        name: 'Milk old',
        productFamilyId: familyId,
        supermarketId: marketId,
        price: 2,
        quantity: 1,
        unitType: 'L',
        pricePerQuantity: 2,
        dateAdded: DateTime(2026, 1, 1),
        isCurrentPrice: false,
        isActive: true,
        barcode: 'X1',
      ),
    );

    final matches = await repository.findCurrentActiveByBarcode('X1');

    expect(matches.length, 1);
    expect(matches.first.productItem.name, 'Milk 1');
  });

  test('registerScannedPrice no-ops when tuple already current', () async {
    final marketId = await repository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );

    await repository.saveQuickProductItem(
      productName: 'Yogurt',
      familyName: 'Yogurt',
      supermarketId: marketId,
      price: 2,
      quantity: 1,
      unitType: 'kg',
      barcode: 'ABC',
    );

    final result = await repository.registerScannedPrice(
      barcode: 'ABC',
      productName: 'Yogurt',
      familyName: 'Yogurt',
      supermarketId: marketId,
      price: 2,
      quantity: 1,
      unitType: 'kg',
    );

    final matches = await repository.findCurrentActiveByBarcode('ABC');
    expect(result.created, false);
    expect(matches.length, 1);
  });

  test('registerScannedPrice rolls over previous current item on change',
      () async {
    final marketId = await repository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );

    await repository.saveQuickProductItem(
      productName: 'Olive Oil',
      familyName: 'Olive Oil',
      supermarketId: marketId,
      price: 5.0,
      quantity: 1,
      unitType: 'L',
      barcode: 'ROLLOVER-1',
    );

    final result = await repository.registerScannedPrice(
      barcode: 'ROLLOVER-1',
      productName: 'Olive Oil',
      familyName: 'Olive Oil',
      supermarketId: marketId,
      price: 6.0,
      quantity: 1,
      unitType: 'L',
    );

    final currentMatches =
        await repository.findCurrentActiveByBarcode('ROLLOVER-1');
    final allRows = await repository.getProductItems(
      supermarketId: marketId,
      onlyCurrentPrice: false,
    );
    final barcodeRows =
        allRows.where((row) => row.barcode == 'ROLLOVER-1').toList();

    expect(result.created, true);
    expect(currentMatches.length, 1);
    expect(currentMatches.first.productItem.price, 6.0);
    expect(barcodeRows.length, 2);
    expect(barcodeRows.where((row) => row.isCurrentPrice).length, 1);
  });

  test(
      'deactivating one supermarket price does not hide shared catalog product in others',
      () async {
    final marketAId = await repository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final marketBId = await repository.saveSupermarket(
      Supermarket(name: 'B', isActive: true),
    );

    await repository.saveQuickProductItem(
      productName: 'Peanuts',
      familyName: 'Peanuts',
      supermarketId: marketAId,
      price: 1.5,
      quantity: 1,
      unitType: 'kg',
      barcode: 'SHARED-1',
    );
    await repository.saveQuickProductItem(
      productName: 'Peanuts',
      familyName: 'Peanuts',
      supermarketId: marketBId,
      price: 1.6,
      quantity: 1,
      unitType: 'kg',
      barcode: 'SHARED-1',
    );

    final before = await repository.getProductItems(onlyCurrentPrice: true);
    final marketAItem =
        before.singleWhere((item) => item.supermarketId == marketAId);

    await repository.saveProductItem(
      ProductItem(
        id: marketAItem.id,
        name: marketAItem.name,
        isActive: false,
        productFamilyId: marketAItem.productFamilyId,
        supermarketId: marketAItem.supermarketId,
        price: marketAItem.price,
        quantity: marketAItem.quantity,
        unitType: marketAItem.unitType,
        pricePerQuantity: marketAItem.pricePerQuantity,
        dateAdded: marketAItem.dateAdded,
        isCurrentPrice: marketAItem.isCurrentPrice,
        barcode: marketAItem.barcode,
        packageQuantityAmount: marketAItem.packageQuantityAmount,
        packageQuantityUnit: marketAItem.packageQuantityUnit,
        normalizedMeasurementUnit: marketAItem.normalizedMeasurementUnit,
      ),
    );

    final after = await repository.getProductItems(onlyCurrentPrice: true);
    expect(
        after.where((item) => item.supermarketId == marketAId && item.isActive),
        isEmpty);
    expect(
      after
          .where((item) => item.supermarketId == marketBId && item.isActive)
          .length,
      1,
    );
    expect(
      (await repository.findCurrentActiveByBarcode('SHARED-1'))
          .where((match) => match.productItem.supermarketId == marketBId)
          .length,
      1,
    );
  });
}
