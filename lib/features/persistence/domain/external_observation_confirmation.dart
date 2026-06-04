import '../../../core/normalization/family_unit_normalization.dart';
import 'entities/external_price_observation.dart';
import 'entities/external_store_mapping.dart';
import 'entities/product_item.dart';

class ExternalObservationConfirmationPlan {
  const ExternalObservationConfirmationPlan({
    required this.localPriceRecord,
  });

  final ProductItem localPriceRecord;
}

class ExternalObservationConfirmationPlanner {
  const ExternalObservationConfirmationPlanner();

  ExternalObservationConfirmationPlan buildPlan({
    required ExternalPriceObservation observation,
    required ExternalStoreMapping? mapping,
    required int productFamilyId,
    required DateTime confirmedAt,
  }) {
    if (observation.id == null) {
      throw StateError('Cannot confirm an observation without a persisted id');
    }

    if (observation.localPriceRecordId != null) {
      throw StateError(
        'Observation ${observation.id} is already confirmed '
        'with local price record ${observation.localPriceRecordId}',
      );
    }

    if (observation.reviewStatus !=
        ExternalObservationReviewStatus.acceptedForComparison) {
      throw StateError(
        'Invalid review status for confirmation: '
        '${observation.reviewStatus}',
      );
    }

    if (mapping == null) {
      throw StateError(
        'Missing external store mapping for ${observation.externalStoreId}',
      );
    }

    final localPriceRecord = ProductItem(
      name: observation.productName,
      productFamilyId: productFamilyId,
      supermarketId: mapping.supermarketId,
      price: observation.price,
      quantity: observation.quantity,
      unitType: observation.unitType,
      pricePerQuantity: observation.pricePerQuantity,
      packageQuantityAmount: observation.quantity,
      packageQuantityUnit: observation.unitType,
      normalizedMeasurementUnit: normalizeUnitTypeForComparison(
        observation.unitType,
      ),
      dateAdded: confirmedAt,
      isCurrentPrice: true,
      externalObservationId: observation.id,
    );

    return ExternalObservationConfirmationPlan(
      localPriceRecord: localPriceRecord,
    );
  }
}
