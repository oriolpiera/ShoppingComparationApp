import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/external_observation_confirmation.dart';

void main() {
  const planner = ExternalObservationConfirmationPlanner();

  ExternalPriceObservation makeObservation({
    int? id = 7,
    ExternalObservationReviewStatus reviewStatus =
        ExternalObservationReviewStatus.acceptedForComparison,
    int? localPriceRecordId,
  }) {
    return ExternalPriceObservation(
      id: id,
      openPricesId: 'op-1',
      productName: 'Milk',
      familyName: 'Milk',
      externalStoreId: 'store-1',
      externalStoreName: 'Open Store',
      price: 1.5,
      quantity: 1,
      unitType: 'l',
      pricePerQuantity: 1.5,
      observedAt: DateTime(2026, 1, 1),
      reviewStatus: reviewStatus,
      localPriceRecordId: localPriceRecordId,
    );
  }

  test('builds a local confirmation plan for accepted observations', () {
    final plan = planner.buildPlan(
      observation: makeObservation(),
      mapping: const ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        supermarketId: 42,
      ),
      productFamilyId: 9,
      confirmedAt: DateTime(2026, 1, 2),
    );

    expect(plan.localPriceRecord.supermarketId, 42);
    expect(plan.localPriceRecord.productFamilyId, 9);
    expect(plan.localPriceRecord.externalObservationId, 7);
    expect(plan.localPriceRecord.dateAdded, DateTime(2026, 1, 2));
  });

  test('rejects missing external store mappings', () {
    expect(
      () => planner.buildPlan(
        observation: makeObservation(),
        mapping: null,
        productFamilyId: 9,
        confirmedAt: DateTime(2026, 1, 2),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('rejects observations that are not review-approved', () {
    expect(
      () => planner.buildPlan(
        observation: makeObservation(
          reviewStatus: ExternalObservationReviewStatus.unreviewed,
        ),
        mapping: const ExternalStoreMapping(
          externalStoreId: 'store-1',
          externalStoreName: 'Open Store',
          supermarketId: 42,
        ),
        productFamilyId: 9,
        confirmedAt: DateTime(2026, 1, 2),
      ),
      throwsA(isA<StateError>()),
    );

    expect(
      () => planner.buildPlan(
        observation: makeObservation(
          reviewStatus: ExternalObservationReviewStatus.discardedForComparison,
        ),
        mapping: const ExternalStoreMapping(
          externalStoreId: 'store-1',
          externalStoreName: 'Open Store',
          supermarketId: 42,
        ),
        productFamilyId: 9,
        confirmedAt: DateTime(2026, 1, 2),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('rejects already confirmed observations', () {
    expect(
      () => planner.buildPlan(
        observation: makeObservation(localPriceRecordId: 99),
        mapping: const ExternalStoreMapping(
          externalStoreId: 'store-1',
          externalStoreName: 'Open Store',
          supermarketId: 42,
        ),
        productFamilyId: 9,
        confirmedAt: DateTime(2026, 1, 2),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('preserves source context on the local record', () {
    final plan = planner.buildPlan(
      observation: makeObservation(),
      mapping: const ExternalStoreMapping(
        externalStoreId: 'store-1',
        externalStoreName: 'Open Store',
        supermarketId: 42,
      ),
      productFamilyId: 9,
      confirmedAt: DateTime(2026, 1, 2),
    );

    expect(plan.localPriceRecord.externalObservationId, 7);
    expect(plan.localPriceRecord.isOpenPricesSource, isTrue);
  });
}
