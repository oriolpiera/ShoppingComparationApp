import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../domain/entities/external_price_observation.dart';
import '../../domain/entities/external_store_mapping.dart';
import '../../domain/external_observation_confirmation.dart';
import '../../domain/external_observation_review_policy.dart';

class DriftExternalObservationRepository {
  final PersistenceDao dao;
  static const ExternalObservationConfirmationPlanner
      _externalObservationConfirmationPlanner =
      ExternalObservationConfirmationPlanner();

  DriftExternalObservationRepository(this.dao);

  Future<List<ExternalStoreMapping>> getExternalStoreMappings() async {
    final rows = await dao.getExternalStoreMappings();
    return rows
        .map(
          (row) => ExternalStoreMapping(
            id: row.id,
            externalStoreId: row.externalStoreId,
            externalStoreName: row.externalStoreName,
            supermarketId: row.supermarketId,
          ),
        )
        .toList();
  }

  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping) {
    return dao.saveExternalStoreMapping(
      ExternalStoreMappingTableCompanion(
        id: mapping.id == null ? const Value.absent() : Value(mapping.id!),
        externalStoreId: Value(mapping.externalStoreId),
        externalStoreName: Value(mapping.externalStoreName),
        supermarketId: Value(mapping.supermarketId),
      ),
    );
  }

  Future<List<ExternalPriceObservation>> getExternalPriceObservations() async {
    final rows = await dao.getExternalPriceObservations();
    return rows
        .map(
          (row) => ExternalPriceObservation(
            id: row.id,
            openPricesId: row.openPricesId,
            productName: row.productName,
            familyName: row.familyName,
            externalStoreId: row.externalStoreId,
            externalStoreName: row.externalStoreName,
            price: row.price,
            quantity: row.quantity,
            unitType: row.unitType,
            pricePerQuantity: row.pricePerQuantity,
            observedAt: row.observedAt,
            reviewStatus: ExternalObservationReviewStatusCodec.fromStorageValue(
              row.reviewStatus,
            ),
            localProductItemId: row.localProductItemId,
            localPriceRecordId: row.localPriceRecordId,
          ),
        )
        .toList();
  }

  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  ) async {
    final existing = observation.id == null
        ? await dao.getExternalPriceObservationByOpenPricesId(
            observation.openPricesId,
          )
        : null;

    return dao.saveExternalPriceObservation(
      ExternalPriceObservationTableCompanion(
        id: observation.id != null
            ? Value(observation.id!)
            : existing == null
                ? const Value.absent()
                : Value(existing.id),
        openPricesId: Value(observation.openPricesId),
        productName: Value(observation.productName),
        familyName: Value(observation.familyName),
        externalStoreId: Value(observation.externalStoreId),
        externalStoreName: Value(observation.externalStoreName),
        price: Value(observation.price),
        quantity: Value(observation.quantity),
        unitType: Value(observation.unitType),
        pricePerQuantity: Value(observation.pricePerQuantity),
        observedAt: Value(observation.observedAt),
        reviewStatus: existing != null
            ? Value(existing.reviewStatus)
            : Value(observation.reviewStatus.storageValue),
        localProductItemId: existing != null
            ? Value(existing.localProductItemId)
            : Value(observation.localProductItemId),
        localPriceRecordId: existing != null
            ? Value(existing.localPriceRecordId)
            : Value(observation.localPriceRecordId),
      ),
    );
  }

  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) async {
    final row = await dao.getExternalPriceObservationById(observationId);
    if (row == null) {
      throw StateError('External observation not found: $observationId');
    }
    final current = ExternalObservationReviewStatusCodec.fromStorageValue(
      row.reviewStatus,
    );
    if (!canTransitionReviewStatus(from: current, to: newStatus)) {
      throw StateError(
        'Invalid review status transition: $current -> $newStatus',
      );
    }

    await dao.saveExternalPriceObservation(
      ExternalPriceObservationTableCompanion(
        id: Value(row.id),
        openPricesId: Value(row.openPricesId),
        productName: Value(row.productName),
        familyName: Value(row.familyName),
        externalStoreId: Value(row.externalStoreId),
        externalStoreName: Value(row.externalStoreName),
        price: Value(row.price),
        quantity: Value(row.quantity),
        unitType: Value(row.unitType),
        pricePerQuantity: Value(row.pricePerQuantity),
        observedAt: Value(row.observedAt),
        reviewStatus: Value(newStatus.storageValue),
        localProductItemId: Value(row.localProductItemId),
        localPriceRecordId: Value(row.localPriceRecordId),
      ),
    );
  }

  ExternalObservationConfirmationPlanner get confirmationPlanner =>
      _externalObservationConfirmationPlanner;
}
