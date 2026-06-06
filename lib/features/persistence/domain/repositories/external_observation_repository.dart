import '../entities/external_price_observation.dart';
import '../entities/external_store_mapping.dart';

abstract class ExternalObservationRepository {
  Future<List<ExternalStoreMapping>> getExternalStoreMappings();

  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping);

  Future<List<ExternalPriceObservation>> getExternalPriceObservations();

  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  );

  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  });

  Future<int> confirmExternalObservationLocally({
    required int observationId,
  });
}
