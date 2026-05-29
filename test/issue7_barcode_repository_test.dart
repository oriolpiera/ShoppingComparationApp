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
}
