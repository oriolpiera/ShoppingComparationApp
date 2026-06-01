import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/external_observation_review_policy.dart';

void main() {
  test('allows expected review status transitions', () {
    expect(
      canTransitionReviewStatus(
        from: ExternalObservationReviewStatus.unreviewed,
        to: ExternalObservationReviewStatus.acceptedForComparison,
      ),
      isTrue,
    );
    expect(
      canTransitionReviewStatus(
        from: ExternalObservationReviewStatus.unreviewed,
        to: ExternalObservationReviewStatus.discardedForComparison,
      ),
      isTrue,
    );
    expect(
      canTransitionReviewStatus(
        from: ExternalObservationReviewStatus.acceptedForComparison,
        to: ExternalObservationReviewStatus.discardedForComparison,
      ),
      isFalse,
    );
  });
}
