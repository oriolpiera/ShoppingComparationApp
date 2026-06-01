enum MeasurementDimension { mass, volume, count }

enum MeasurementUnit {
  gram(dimension: MeasurementDimension.mass, toBaseFactor: 1),
  kilogram(dimension: MeasurementDimension.mass, toBaseFactor: 1000),
  milliliter(dimension: MeasurementDimension.volume, toBaseFactor: 1),
  liter(dimension: MeasurementDimension.volume, toBaseFactor: 1000),
  unit(dimension: MeasurementDimension.count, toBaseFactor: 1);

  const MeasurementUnit({required this.dimension, required this.toBaseFactor});

  final MeasurementDimension dimension;
  final double toBaseFactor;

  bool isCompatibleWith(MeasurementUnit other) => dimension == other.dimension;

  double toBase(double quantity) => quantity * toBaseFactor;

  double convert(double quantity, MeasurementUnit to) {
    if (!isCompatibleWith(to)) {
      throw UnitCompatibilityException(this, to);
    }
    final inBase = toBase(quantity);
    return inBase / to.toBaseFactor;
  }
}

class UnitCompatibilityException implements Exception {
  UnitCompatibilityException(this.from, this.to);

  final MeasurementUnit from;
  final MeasurementUnit to;

  @override
  String toString() =>
      'Incompatible measurement units: ${from.name} and ${to.name}';
}
