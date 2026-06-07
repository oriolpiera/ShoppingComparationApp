import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:shopping_comparation_app/features/persistence/data/repositories/drift_persistence_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/supermarket.dart';

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
    final marketId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Milk', isActive: true),
    );

    await repository.priceRecordRepository.saveProductItem(
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
    await repository.priceRecordRepository.saveProductItem(
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

    final matches =
        await repository.priceRecordRepository.findCurrentActiveByBarcode('X1');

    expect(matches.length, 1);
    expect(matches.first.catalogProduct.name, 'Milk 1');
    expect(matches.first.catalogProduct.barcode, 'X1');
    expect(matches.first.priceRecord.price, 1);
  });

  test('registerScannedPrice no-ops when tuple already current', () async {
    final marketId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Test Family'),
    );

    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Yogurt',
      familyId: familyId,
      supermarketId: marketId,
      price: 2,
      quantity: 1,
      unitType: 'kg',
      barcode: 'ABC',
    );

    final result = await repository.priceRecordRepository.registerScannedPrice(
      barcode: 'ABC',
      productName: 'Yogurt',
      familyId: familyId,
      supermarketId: marketId,
      price: 2,
      quantity: 1,
      unitType: 'kg',
    );

    final matches = await repository.priceRecordRepository
        .findCurrentActiveByBarcode('ABC');
    expect(result.created, false);
    expect(result.catalogProduct?.barcode, 'ABC');
    expect(result.priceRecord?.price, 2);
    expect(matches.length, 1);
    expect(
      (await db
              .customSelect('SELECT COUNT(*) AS c FROM catalog_product;')
              .getSingle())
          .read<int>('c'),
      1,
    );
    expect(
      (await db
              .customSelect('SELECT COUNT(*) AS c FROM price_record;')
              .getSingle())
          .read<int>('c'),
      1,
    );
  });

  test('registerScannedPrice with empty barcode returns no domain objects',
      () async {
    final result = await repository.priceRecordRepository.registerScannedPrice(
      barcode: '   ',
      productName: 'Yogurt',
      familyId: 1,
      supermarketId: 1,
      price: 2,
      quantity: 1,
      unitType: 'kg',
    );

    expect(result.created, false);
    expect(result.catalogProduct, isNull);
    expect(result.priceRecord, isNull);
    expect(result.message, 'Barcode is required.');
  });

  test('registerScannedPrice rolls over previous current item on change',
      () async {
    final marketId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Test Family'),
    );

    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Olive Oil',
      familyId: familyId,
      supermarketId: marketId,
      price: 5.0,
      quantity: 1,
      unitType: 'L',
      barcode: 'ROLLOVER-1',
    );

    final result = await repository.priceRecordRepository.registerScannedPrice(
      barcode: 'ROLLOVER-1',
      productName: 'Olive Oil',
      familyId: familyId,
      supermarketId: marketId,
      price: 6.0,
      quantity: 1,
      unitType: 'L',
    );

    final currentMatches = await repository.priceRecordRepository
        .findCurrentActiveByBarcode('ROLLOVER-1');
    final allRows = await repository.priceRecordRepository.getProductItems(
      supermarketId: marketId,
      onlyCurrentPrice: false,
    );
    final barcodeRows =
        allRows.where((row) => row.barcode == 'ROLLOVER-1').toList();

    expect(result.created, true);
    expect(currentMatches.length, 1);
    expect(currentMatches.first.catalogProduct.barcode, 'ROLLOVER-1');
    expect(currentMatches.first.priceRecord.price, 6.0);
    expect(result.catalogProduct?.id, currentMatches.first.catalogProduct.id);
    expect(result.priceRecord?.id, currentMatches.first.priceRecord.id);
    expect(barcodeRows.length, 2);
    expect(barcodeRows.where((row) => row.isCurrentPrice).length, 1);
    expect(
      (await db
              .customSelect(
                "SELECT COUNT(*) AS c FROM catalog_product WHERE barcode = 'ROLLOVER-1';",
              )
              .getSingle())
          .read<int>('c'),
      1,
    );
    expect(
      (await db
              .customSelect('SELECT COUNT(*) AS c FROM price_record;')
              .getSingle())
          .read<int>('c'),
      2,
    );
  });

  test(
      'deactivating one supermarket price does not hide shared catalog product in others',
      () async {
    final marketAId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final marketBId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'B', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Test Family'),
    );

    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Peanuts',
      familyId: familyId,
      supermarketId: marketAId,
      price: 1.5,
      quantity: 1,
      unitType: 'kg',
      barcode: 'SHARED-1',
    );
    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Peanuts',
      familyId: familyId,
      supermarketId: marketBId,
      price: 1.6,
      quantity: 1,
      unitType: 'kg',
      barcode: 'SHARED-1',
    );

    final before = await repository.priceRecordRepository
        .getProductItems(onlyCurrentPrice: true);
    final marketAItem =
        before.singleWhere((item) => item.supermarketId == marketAId);

    await repository.priceRecordRepository.saveProductItem(
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

    final after = await repository.priceRecordRepository
        .getProductItems(onlyCurrentPrice: true);
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
      (await repository.priceRecordRepository
              .findCurrentActiveByBarcode('SHARED-1'))
          .where((match) => match.productItem.supermarketId == marketBId)
          .length,
      1,
    );
    expect(
      (await repository.priceRecordRepository
              .findCurrentActiveByBarcode('SHARED-1'))
          .where((match) => match.productItem.supermarketId == marketAId),
      isEmpty,
    );
  });

  test('editing a product into an existing identity throws a conflict error',
      () async {
    final marketId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );

    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Milk Whole',
      familyId: 1,
      supermarketId: marketId,
      price: 1.5,
      quantity: 1,
      unitType: 'L',
      barcode: 'BAR-1',
    );
    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Milk Skim',
      familyId: 1,
      supermarketId: marketId,
      price: 1.6,
      quantity: 1,
      unitType: 'L',
      barcode: 'BAR-2',
    );

    final items = await repository.priceRecordRepository
        .getProductItems(onlyCurrentPrice: true);
    final second = items.singleWhere((item) => item.barcode == 'BAR-2');

    expect(
      () => repository.priceRecordRepository.saveProductItem(
        ProductItem(
          id: second.id,
          name: second.name,
          isActive: second.isActive,
          productFamilyId: second.productFamilyId,
          supermarketId: second.supermarketId,
          price: second.price,
          quantity: second.quantity,
          unitType: second.unitType,
          pricePerQuantity: second.pricePerQuantity,
          dateAdded: second.dateAdded,
          isCurrentPrice: second.isCurrentPrice,
          barcode: 'BAR-1',
          packageQuantityAmount: second.packageQuantityAmount,
          packageQuantityUnit: second.packageQuantityUnit,
          normalizedMeasurementUnit: second.normalizedMeasurementUnit,
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test(
      'saving a new inactive current price does not deactivate the shared catalog product',
      () async {
    final marketAId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'A', isActive: true),
    );
    final marketBId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'B', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Milk', isActive: true),
    );

    await repository.priceRecordRepository.saveQuickProductItem(
      productName: 'Milk',
      familyId: 1,
      supermarketId: marketAId,
      price: 1.5,
      quantity: 1,
      unitType: 'L',
      barcode: 'CAT-SHARED-1',
    );

    await repository.priceRecordRepository.saveProductItem(
      ProductItem(
        name: 'Milk',
        isActive: false,
        productFamilyId: familyId,
        supermarketId: marketBId,
        price: 1.6,
        quantity: 1,
        unitType: 'L',
        pricePerQuantity: 1.6,
        dateAdded: DateTime(2026, 2, 1),
        isCurrentPrice: true,
        barcode: 'CAT-SHARED-1',
        packageQuantityAmount: 1,
        packageQuantityUnit: 'L',
        normalizedMeasurementUnit: 'l',
      ),
    );

    final currentItems = await repository.priceRecordRepository
        .getProductItems(onlyCurrentPrice: true);
    expect(
      currentItems
          .where((item) => item.supermarketId == marketAId && item.isActive)
          .length,
      1,
    );
    expect(
      currentItems
          .where((item) => item.supermarketId == marketBId && item.isActive),
      isEmpty,
    );
    expect(
      (await repository.priceRecordRepository
              .findCurrentActiveByBarcode('CAT-SHARED-1'))
          .where((match) => match.productItem.supermarketId == marketAId)
          .length,
      1,
    );
  });
}
