import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:shopping_comparation_app/features/persistence/data/repositories/drift_persistence_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/supermarket.dart';

void main() {
  late AppDriftDatabase db;
  late DriftPersistenceRepository repository;

  setUp(() {
    db = AppDriftDatabase.forTesting(NativeDatabase.memory());
    repository = DriftPersistenceRepository.fromDatabase(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('exports and reimports backup scope with price history intact',
      () async {
    final supermarketId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'Market', address: 'Street 1', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(
        name: 'Rice',
        shoppingUnit: 'kilogram',
        purchaseMode: 'packaged',
      ),
    );

    await repository.priceRecordRepository.saveProductItem(
      ProductItem(
        name: 'Rice bag',
        productFamilyId: familyId,
        supermarketId: supermarketId,
        price: 2.4,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 2.4,
        packageQuantityAmount: 1,
        packageQuantityUnit: 'kg',
        normalizedMeasurementUnit: 'kg',
        dateAdded: DateTime(2026, 1, 1),
      ),
    );
    await repository.priceRecordRepository.saveProductItem(
      ProductItem(
        name: 'Rice bag',
        productFamilyId: familyId,
        supermarketId: supermarketId,
        price: 2.8,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 2.8,
        packageQuantityAmount: 1,
        packageQuantityUnit: 'kg',
        normalizedMeasurementUnit: 'kg',
        dateAdded: DateTime(2026, 2, 1),
      ),
    );
    await repository.shoppingListRepository.saveShoppingNeedEntry(
      ShoppingListEntry(productFamilyId: familyId, quantity: 3),
    );

    final backupJson = await repository.backupRepository.exportBackupJson();
    final backupMap = jsonDecode(backupJson) as Map<String, dynamic>;

    expect(backupMap['schemaVersion'], 1);
    expect((backupMap['supermarkets'] as List).length, 1);
    expect((backupMap['productFamilies'] as List).length, 1);
    expect((backupMap['catalogProducts'] as List).length, 1);
    expect((backupMap['priceRecords'] as List).length, 2);
    expect((backupMap['shoppingListEntries'] as List).length, 1);

    await repository.backupRepository.importBackupJson(backupJson);

    final supermarkets = await repository.supermarketRepository.getSupermarkets(onlyActive: false);
    final families = await repository.productFamilyRepository.getProductFamilies(onlyActive: false);
    final items = await repository.priceRecordRepository.getProductItems(onlyCurrentPrice: false);
    final shoppingList = await repository.shoppingListRepository.getShoppingNeedEntries();

    expect(supermarkets.single.name, 'Market');
    expect(families.single.name, 'Rice');
    expect(items, hasLength(2));
    expect(items.where((item) => item.isCurrentPrice), hasLength(1));
    expect(items.map((item) => item.price), containsAll(<double>[2.4, 2.8]));
    expect(shoppingList.single.quantity, 3);
  });

  test('rejects backup payloads with broken references', () async {
    const invalidJson = '''
{
  "schemaVersion": 1,
  "exportedAt": "2026-06-04T00:00:00.000Z",
  "supermarkets": [],
  "productFamilies": [],
  "catalogProducts": [],
  "priceRecords": [],
  "shoppingListEntries": [
    {"id": 1, "productFamilyId": 999, "quantity": 2}
  ]
}
''';

    expect(
      () => repository.backupRepository.importBackupJson(invalidJson),
      throwsA(isA<FormatException>()),
    );
  });

  test('keeps external mappings and observations not included in backup',
      () async {
    final supermarketId = await repository.supermarketRepository.saveSupermarket(
      Supermarket(name: 'Market', isActive: true),
    );
    final familyId = await repository.productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Rice'),
    );

    await repository.externalObservationRepository.saveExternalStoreMapping(
      ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'OpenPrices Market',
        supermarketId: supermarketId,
      ),
    );
    await repository.externalObservationRepository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'obs-1',
        productName: 'Rice bag',
        familyName: 'Rice',
        externalStoreId: 'store-1',
        externalStoreName: 'OpenPrices Market',
        price: 2.3,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 2.3,
        observedAt: DateTime(2026, 1, 1),
      ),
    );

    await repository.priceRecordRepository.saveProductItem(
      ProductItem(
        name: 'Rice bag',
        productFamilyId: familyId,
        supermarketId: supermarketId,
        price: 2.4,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 2.4,
        packageQuantityAmount: 1,
        packageQuantityUnit: 'kg',
        normalizedMeasurementUnit: 'kg',
        dateAdded: DateTime(2026, 1, 1),
      ),
    );

    final backupJson = await repository.backupRepository.exportBackupJson();

    await repository.backupRepository.importBackupJson(backupJson);

    final mappings = await repository.externalObservationRepository.getExternalStoreMappings();
    final observations = await repository.externalObservationRepository.getExternalPriceObservations();

    expect(mappings, hasLength(1));
    expect(mappings.single.externalStoreId, 'store-1');
    expect(observations, hasLength(1));
    expect(observations.single.openPricesId, 'obs-1');
  });
}
