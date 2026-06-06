import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/database/drift_database.dart';
import 'package:shopping_comparation_app/features/persistence/data/repositories/drift_persistence_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
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

  test('unreviewed observations do not create local current prices', () async {
    await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-1',
        productName: 'Milk 1L',
        familyName: 'Milk',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 1.5,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 1.5,
        observedAt: DateTime(2026, 1, 1),
      ),
    );

    final items = await repository.getProductItems(onlyCurrentPrice: true);
    expect(items, isEmpty);
  });

  test('accepted observations participate in optimization and are tagged',
      () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Local Market'),
    );
    final familyId = await repository.saveProductFamily(
      const ProductFamily(name: 'Milk'),
    );
    await repository.saveShoppingListEntry(
      ShoppingListEntry(productFamilyId: familyId, quantity: 1),
    );
    await repository.saveExternalStoreMapping(
      ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        supermarketId: supermarketId,
      ),
    );

    final observationId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-2',
        productName: 'Milk branded',
        familyName: 'Milk',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 1.0,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 1.0,
        observedAt: DateTime(2026, 1, 2),
      ),
    );

    await repository.updateExternalObservationReviewStatus(
      observationId: observationId,
      newStatus: ExternalObservationReviewStatus.acceptedForComparison,
    );

    final optimized = await repository.getOptimizedShoppingList();
    expect(optimized.single.items.single.sourceTag, 'OpenPrices');
  });

  test('accepted observations participate in shopping need seam optimization',
      () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Local Market'),
    );
    final familyId = await repository.saveProductFamily(
      const ProductFamily(name: 'Milk'),
    );
    await repository.saveShoppingListEntry(
      ShoppingListEntry(productFamilyId: familyId, quantity: 1),
    );
    await repository.saveExternalStoreMapping(
      ExternalStoreMapping(
        externalStoreId: 'store-need-1',
        externalStoreName: 'Open Store',
        supermarketId: supermarketId,
      ),
    );

    final observationId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-need-1',
        productName: 'Milk seam candidate',
        familyName: 'Milk',
        externalStoreId: 'store-need-1',
        externalStoreName: 'Open Store',
        price: 0.9,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 0.9,
        observedAt: DateTime(2026, 1, 2),
      ),
    );

    await repository.updateExternalObservationReviewStatus(
      observationId: observationId,
      newStatus: ExternalObservationReviewStatus.acceptedForComparison,
    );

    final optimized = await repository.getOptimizedShoppingNeedEntries();
    expect(optimized.groups, hasLength(1));
    expect(optimized.groups.single.entries, hasLength(1));
    expect(optimized.groups.single.entries.single.bestItem.name,
        'Milk seam candidate');
    expect(
      optimized.groups.single.entries.single.bestItem.isOpenPricesSource,
      isTrue,
    );
  });

  test(
      'confirming external observation creates local product item with source link',
      () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Local Market'),
    );
    await repository.saveExternalStoreMapping(
      ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        supermarketId: supermarketId,
      ),
    );

    final observationId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-3',
        productName: 'Bread',
        familyName: 'Bread',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 2.0,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 2.0,
        observedAt: DateTime(2026, 1, 3),
      ),
    );

    await repository.updateExternalObservationReviewStatus(
      observationId: observationId,
      newStatus: ExternalObservationReviewStatus.acceptedForComparison,
    );

    final productItemId = await repository.confirmExternalObservationLocally(
      observationId: observationId,
    );

    final items = await repository.getProductItems(onlyCurrentPrice: true);
    expect(items.single.id, productItemId);
    expect(items.single.externalObservationId, observationId);

    final observations = await repository.getExternalPriceObservations();
    final confirmed = observations.singleWhere((o) => o.id == observationId);
    expect(
      confirmed.reviewStatus,
      ExternalObservationReviewStatus.acceptedForComparison,
    );
    expect(confirmed.localProductItemId, isNull);
    expect(confirmed.localPriceRecordId, productItemId);
  });

  test('missing mapping rejection leaves no local product item behind',
      () async {
    final observationId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-3-missing-mapping',
        productName: 'Bread',
        familyName: 'Bread',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 2.0,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 2.0,
        observedAt: DateTime(2026, 1, 3),
      ),
    );

    await repository.updateExternalObservationReviewStatus(
      observationId: observationId,
      newStatus: ExternalObservationReviewStatus.acceptedForComparison,
    );

    await expectLater(
      repository.confirmExternalObservationLocally(
        observationId: observationId,
      ),
      throwsA(isA<StateError>()),
    );

    final items = await repository.getProductItems(onlyCurrentPrice: true);
    expect(items, isEmpty);

    final confirmed = (await repository.getExternalPriceObservations())
        .singleWhere((o) => o.id == observationId);
    expect(confirmed.localPriceRecordId, isNull);
    expect(
      confirmed.reviewStatus,
      ExternalObservationReviewStatus.acceptedForComparison,
    );
  });

  test(
      'confirmed observations are not re-injected as separate optimizer candidates',
      () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Local Market'),
    );
    final familyId = await repository.saveProductFamily(
      const ProductFamily(name: 'Milk'),
    );
    await repository.saveShoppingListEntry(
      ShoppingListEntry(productFamilyId: familyId, quantity: 1),
    );
    await repository.saveExternalStoreMapping(
      ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        supermarketId: supermarketId,
      ),
    );

    final observationId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-4',
        productName: 'Milk 1L',
        familyName: 'Milk',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 1.2,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 1.2,
        observedAt: DateTime(2026, 1, 4),
      ),
    );

    await repository.updateExternalObservationReviewStatus(
      observationId: observationId,
      newStatus: ExternalObservationReviewStatus.acceptedForComparison,
    );

    await repository.confirmExternalObservationLocally(
      observationId: observationId,
    );

    final itemsAfterFirstConfirmation = await repository.getProductItems(
      onlyCurrentPrice: true,
    );
    expect(itemsAfterFirstConfirmation, hasLength(1));
    final confirmedItemId = itemsAfterFirstConfirmation.single.id;

    await expectLater(
      repository.confirmExternalObservationLocally(
        observationId: observationId,
      ),
      throwsA(isA<StateError>()),
    );

    final itemsAfterRejectedSecondConfirmation =
        await repository.getProductItems(onlyCurrentPrice: true);
    expect(itemsAfterRejectedSecondConfirmation, hasLength(1));
    expect(itemsAfterRejectedSecondConfirmation.single.id, confirmedItemId);

    final confirmed = (await repository.getExternalPriceObservations())
        .singleWhere((o) => o.id == observationId);
    expect(confirmed.localPriceRecordId, confirmedItemId);

    final optimized = await repository.getOptimizedShoppingList();
    expect(optimized, hasLength(1));
    expect(optimized.single.items, hasLength(1));
    expect(optimized.single.items.single.sourceTag, 'OpenPrices');
  });

  test('confirming discarded observation does not create orphan product item',
      () async {
    final supermarketId = await repository.saveSupermarket(
      Supermarket(name: 'Local Market'),
    );
    await repository.saveExternalStoreMapping(
      ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        supermarketId: supermarketId,
      ),
    );

    final observationId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-5',
        productName: 'Discarded Milk',
        familyName: 'Milk',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 1.6,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 1.6,
        observedAt: DateTime(2026, 1, 5),
        reviewStatus: ExternalObservationReviewStatus.discardedForComparison,
      ),
    );

    await expectLater(
      repository.confirmExternalObservationLocally(
        observationId: observationId,
      ),
      throwsA(isA<StateError>()),
    );

    final currentItems =
        await repository.getProductItems(onlyCurrentPrice: true);
    expect(
      currentItems.where((item) => item.externalObservationId == observationId),
      isEmpty,
    );
  });

  test(
      'saving same openPricesId updates existing observation instead of duplicating',
      () async {
    final firstId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-dup-1',
        productName: 'Milk A',
        familyName: 'Milk',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 1.1,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 1.1,
        observedAt: DateTime(2026, 1, 1),
      ),
    );

    final secondId = await repository.saveExternalPriceObservation(
      ExternalPriceObservation(
        openPricesId: 'op-dup-1',
        productName: 'Milk B',
        familyName: 'Milk',
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        price: 1.3,
        quantity: 1,
        unitType: 'l',
        pricePerQuantity: 1.3,
        observedAt: DateTime(2026, 1, 2),
      ),
    );

    expect(secondId, firstId);

    final observations = await repository.getExternalPriceObservations();
    expect(
        observations.where((o) => o.openPricesId == 'op-dup-1'), hasLength(1));
    expect(
      observations.singleWhere((o) => o.openPricesId == 'op-dup-1').productName,
      'Milk B',
    );
  });
}
