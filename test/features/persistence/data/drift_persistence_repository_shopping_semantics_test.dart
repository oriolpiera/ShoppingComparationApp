import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:shopping_comparation_app/features/persistence/data/repositories/drift_persistence_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

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

  test('round-trips family and item shopping semantics fields', () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Market', isActive: true),
    );

    final familyId = await repository.saveProductFamily(
      const ProductFamily(
        name: 'Rice',
        shoppingUnit: 'kilogram',
        purchaseMode: 'packaged',
      ),
    );

    await repository.saveProductItem(
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

    final families = await repository.getProductFamilies(onlyActive: false);
    final items = await repository.getProductItems(
      productFamilyId: familyId,
      supermarketId: supermarketId,
      onlyCurrentPrice: false,
    );

    expect(families.single.shoppingUnit, 'kilogram');
    expect(families.single.purchaseMode, 'packaged');
    expect(items.single.packageQuantityAmount, 1);
    expect(items.single.packageQuantityUnit, 'kg');
    expect(items.single.normalizedMeasurementUnit, 'kg');
  });

  test('quick capture infers piece semantics for unit-based families',
      () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Market', isActive: true),
    );

    final itemId = await repository.saveQuickProductItem(
      productName: 'Eggs 6-pack',
      familyName: 'Eggs',
      supermarketId: supermarketId,
      price: 2.4,
      quantity: 6,
      unitType: 'unit',
    );

    final items = await repository.getProductItems(
      supermarketId: supermarketId,
      onlyCurrentPrice: false,
    );
    final item = items.singleWhere((candidate) => candidate.id == itemId);
    final families = await repository.getProductFamilies(onlyActive: false);

    expect(item.unitType, 'unit');
    expect(item.packageQuantityAmount, 6);
    expect(item.packageQuantityUnit, 'unit');
    expect(item.normalizedMeasurementUnit, 'unit');
    expect(families.single.shoppingUnit, 'piece');
    expect(families.single.purchaseMode, 'piece');
  });
}
