import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/units/measurement.dart';
import 'package:shopping_comparation_app/features/persistence/domain/units/shopping_units.dart';

void main() {
  group('MeasurementUnit', () {
    test('normalizes and converts compatible units', () {
      expect(MeasurementUnit.kilogram.toBase(1.25), 1250);
      expect(MeasurementUnit.kilogram.convert(1, MeasurementUnit.gram), 1000);
      expect(MeasurementUnit.milliliter.convert(500, MeasurementUnit.liter), 0.5);
    });

    test('throws on incompatible conversion', () {
      expect(
        () => MeasurementUnit.gram.convert(1, MeasurementUnit.liter),
        throwsA(isA<UnitCompatibilityException>()),
      );
    });
  });

  group('FamilyOffer validation', () {
    test('rejects weighted mode with count unit', () {
      expect(
        () => FamilyOffer(
          id: 'a',
          price: 3,
          purchaseMode: PurchaseMode.weighted,
          packageQuantity: PackageQuantity(amount: 1, unit: MeasurementUnit.unit),
        ),
        throwsArgumentError,
      );
    });

    test('rejects piece mode with non-count unit', () {
      expect(
        () => FamilyOffer(
          id: 'a',
          price: 3,
          purchaseMode: PurchaseMode.piece,
          packageQuantity: PackageQuantity(amount: 1, unit: MeasurementUnit.gram),
        ),
        throwsArgumentError,
      );
    });
  });

  group('Family winner selection', () {
    test('uses family need independent from package size', () {
      final need = FamilyNeedQuantity(amount: 1.5, unit: ShoppingUnit.kilogram);

      final winner = selectFamilyWinner(
        need: need,
        offers: [
          FamilyOffer(
            id: 'bulk',
            price: 4,
            purchaseMode: PurchaseMode.weighted,
            packageQuantity: PackageQuantity(amount: 1, unit: MeasurementUnit.kilogram),
          ),
          FamilyOffer(
            id: 'pack500',
            price: 1.5,
            purchaseMode: PurchaseMode.packaged,
            packageQuantity: PackageQuantity(amount: 500, unit: MeasurementUnit.gram),
          ),
        ],
      );

      expect(winner?.id, 'pack500');
    });

    test('throws when need and offer units are incompatible', () {
      final need = FamilyNeedQuantity(amount: 1, unit: ShoppingUnit.kilogram);
      final offer = FamilyOffer(
        id: 'vol',
        price: 1,
        purchaseMode: PurchaseMode.packaged,
        packageQuantity: PackageQuantity(amount: 1, unit: MeasurementUnit.liter),
      );

      expect(
        () => offer.totalCostFor(need),
        throwsA(isA<UnitCompatibilityException>()),
      );
    });
  });
}
