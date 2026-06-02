import 'measurement.dart';

const _doubleEpsilon = 1e-9;

enum ShoppingUnit {
  kilogram(MeasurementUnit.kilogram),
  liter(MeasurementUnit.liter),
  piece(MeasurementUnit.unit);

  const ShoppingUnit(this.measurementUnit);

  final MeasurementUnit measurementUnit;
}

enum PurchaseMode { weighted, packaged, piece }

class PackageQuantity {
  PackageQuantity({required this.amount, required this.unit}) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than zero');
    }
  }

  final double amount;
  final MeasurementUnit unit;

  double get normalizedAmount => unit.toBase(amount);
}

class FamilyNeedQuantity {
  FamilyNeedQuantity({required this.amount, required this.unit}) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than zero');
    }
  }

  final double amount;
  final ShoppingUnit unit;

  double get normalizedAmount => unit.measurementUnit.toBase(amount);
}

class FamilyOffer {
  FamilyOffer({
    required this.id,
    required this.price,
    required this.purchaseMode,
    required this.packageQuantity,
  }) {
    if (price <= 0) {
      throw ArgumentError.value(price, 'price', 'must be greater than zero');
    }

    if (purchaseMode == PurchaseMode.weighted &&
        packageQuantity.unit.dimension == MeasurementDimension.count) {
      throw ArgumentError('Weighted mode requires mass or volume units');
    }

    if (purchaseMode == PurchaseMode.piece) {
      if (packageQuantity.unit.dimension != MeasurementDimension.count) {
        throw ArgumentError('Piece mode requires count units');
      }
    }
  }

  final String id;
  final double price;
  final PurchaseMode purchaseMode;
  final PackageQuantity packageQuantity;

  double totalCostFor(FamilyNeedQuantity need) {
    if (!need.unit.measurementUnit.isCompatibleWith(packageQuantity.unit)) {
      throw UnitCompatibilityException(
          need.unit.measurementUnit, packageQuantity.unit);
    }

    final needed = need.normalizedAmount;
    final perPackage = packageQuantity.normalizedAmount;

    return switch (purchaseMode) {
      PurchaseMode.weighted => (needed / perPackage) * price,
      PurchaseMode.packaged ||
      PurchaseMode.piece =>
        (needed / perPackage).ceil() * price,
    };
  }
}

FamilyOffer? selectFamilyWinner({
  required FamilyNeedQuantity need,
  required Iterable<FamilyOffer> offers,
}) {
  FamilyOffer? winner;
  double? winnerCost;

  for (final offer in offers) {
    final cost = offer.totalCostFor(need);
    if (winner == null || cost < winnerCost! - _doubleEpsilon) {
      winner = offer;
      winnerCost = cost;
      continue;
    }

    final isTie = (cost - winnerCost).abs() <= _doubleEpsilon;
    if (isTie && offer.id.compareTo(winner.id) < 0) {
      winner = offer;
      winnerCost = cost;
    }
  }

  return winner;
}
