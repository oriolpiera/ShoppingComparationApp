enum ExternalObservationReviewStatus {
  unreviewed,
  acceptedForComparison,
  discardedForComparison,
}

extension ExternalObservationReviewStatusCodec
    on ExternalObservationReviewStatus {
  String get storageValue => switch (this) {
        ExternalObservationReviewStatus.unreviewed => 'unreviewed',
        ExternalObservationReviewStatus.acceptedForComparison =>
          'accepted_for_comparison',
        ExternalObservationReviewStatus.discardedForComparison =>
          'discarded_for_comparison',
      };

  static ExternalObservationReviewStatus fromStorageValue(String raw) {
    return switch (raw) {
      'accepted_for_comparison' =>
        ExternalObservationReviewStatus.acceptedForComparison,
      'discarded_for_comparison' =>
        ExternalObservationReviewStatus.discardedForComparison,
      _ => ExternalObservationReviewStatus.unreviewed,
    };
  }
}

class ExternalPriceObservation {
  const ExternalPriceObservation({
    this.id,
    required this.openPricesId,
    required this.productName,
    required this.familyName,
    required this.externalStoreId,
    required this.externalStoreName,
    required this.price,
    required this.quantity,
    required this.unitType,
    required this.pricePerQuantity,
    required this.observedAt,
    this.reviewStatus = ExternalObservationReviewStatus.unreviewed,
    this.localProductItemId,
  });

  final int? id;
  final String openPricesId;
  final String productName;
  final String familyName;
  final String externalStoreId;
  final String externalStoreName;
  final double price;
  final double quantity;
  final String unitType;
  final double pricePerQuantity;
  final DateTime observedAt;
  final ExternalObservationReviewStatus reviewStatus;
  final int? localProductItemId;
}
