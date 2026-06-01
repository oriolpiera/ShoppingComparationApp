import 'entities/external_price_observation.dart';

bool canTransitionReviewStatus({
  required ExternalObservationReviewStatus from,
  required ExternalObservationReviewStatus to,
}) {
  if (from == to) return true;
  return switch (from) {
    ExternalObservationReviewStatus.unreviewed =>
      to == ExternalObservationReviewStatus.acceptedForComparison ||
          to == ExternalObservationReviewStatus.discardedForComparison,
    ExternalObservationReviewStatus.acceptedForComparison ||
    ExternalObservationReviewStatus.discardedForComparison =>
      to == ExternalObservationReviewStatus.unreviewed,
  };
}
