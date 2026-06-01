import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/units/measurement.dart';
import 'package:shopping_comparation_app/features/persistence/domain/units/shopping_units.dart';

void main() {
  group('MeasurementUnit', () {
    test('normalizes and converts compatible units', () {
      expect(MeasurementUnit.kilogram.toBase(1.25), 1250);
      expect(MeasurementUnit.kilogram.convert(1, MeasurementUnit.gram), 1000);
      expect(
          MeasurementUnit.milliliter.convert(500, MeasurementUnit.liter), 0.5);
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
          packageQuantity:
              PackageQuantity(amount: 1, unit: MeasurementUnit.unit),
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
          packageQuantity:
              PackageQuantity(amount: 1, unit: MeasurementUnit.gram),
        ),
        throwsArgumentError,
      );
    });

    test('rejects piece mode when amount is not one', () {
      expect(
        () => FamilyOffer(
          id: 'a',
          price: 3,
          purchaseMode: PurchaseMode.piece,
          packageQuantity:
              PackageQuantity(amount: 2, unit: MeasurementUnit.unit),
        ),
        throwsArgumentError,
      );
    });
  });

  group('FamilyOffer total cost', () {
    test('packaged mode never buys fractional packages', () {
      final offer = FamilyOffer(
        id: 'pack300',
        price: 1,
        purchaseMode: PurchaseMode.packaged,
        packageQuantity:
            PackageQuantity(amount: 300, unit: MeasurementUnit.milliliter),
      );

      final total = offer
          .totalCostFor(FamilyNeedQuantity(amount: 1, unit: ShoppingUnit.liter));

      expect(total, 4);
    });

    test('weighted mode allows divisible quantities', () {
      final offer = FamilyOffer(
        id: 'bulk',
        price: 10,
        purchaseMode: PurchaseMode.weighted,
        packageQuantity:
            PackageQuantity(amount: 1, unit: MeasurementUnit.kilogram),
      );

      final total = offer.totalCostFor(
        FamilyNeedQuantity(amount: 0.25, unit: ShoppingUnit.kilogram),
      );

      expect(total, 2.5);
    });

    test('piece mode uses discrete counts', () {
      final offer = FamilyOffer(
        id: 'piece',
        price: 2,
        purchaseMode: PurchaseMode.piece,
        packageQuantity: PackageQuantity(amount: 1, unit: MeasurementUnit.unit),
      );

      final total =
          offer.totalCostFor(FamilyNeedQuantity(amount: 3, unit: ShoppingUnit.piece));

      expect(total, 6);
    });

    test('throws when need and offer units are incompatible', () {
      final need = FamilyNeedQuantity(amount: 1, unit: ShoppingUnit.kilogram);
      final offer = FamilyOffer(
        id: 'vol',
        price: 1,
        purchaseMode: PurchaseMode.packaged,
        packageQuantity:
            PackageQuantity(amount: 1, unit: MeasurementUnit.liter),
      );

      expect(
        () => offer.totalCostFor(need),
        throwsA(isA<UnitCompatibilityException>()),
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
            packageQuantity:
                PackageQuantity(amount: 1, unit: MeasurementUnit.kilogram),
          ),
          FamilyOffer(
            id: 'pack500',
            price: 1.5,
            purchaseMode: PurchaseMode.packaged,
            packageQuantity:
                PackageQuantity(amount: 500, unit: MeasurementUnit.gram),
          ),
        ],
      );

      expect(winner?.id, 'pack500');
    });

    test('selects cheapest packaged offer for 1L need (250ml/300ml/1L)', () {
      final need = FamilyNeedQuantity(amount: 1, unit: ShoppingUnit.liter);

      final winner = selectFamilyWinner(
        need: need,
        offers: [
          FamilyOffer(
            id: '250ml',
            price: 0.7,
            purchaseMode: PurchaseMode.packaged,
            packageQuantity:
                PackageQuantity(amount: 250, unit: MeasurementUnit.milliliter),
          ),
          FamilyOffer(
            id: '300ml',
            price: 0.65,
            purchaseMode: PurchaseMode.packaged,
            packageQuantity:
                PackageQuantity(amount: 300, unit: MeasurementUnit.milliliter),
          ),
          FamilyOffer(
            id: '1l',
            price: 2.7,
            purchaseMode: PurchaseMode.packaged,
            packageQuantity:
                PackageQuantity(amount: 1, unit: MeasurementUnit.liter),
          ),
        ],
      );

      expect(winner?.id, '300ml');
    });

    test('uses lexicographic id as tie-breaker for equal costs', () {
      final need = FamilyNeedQuantity(amount: 2, unit: ShoppingUnit.kilogram);

      final winner = selectFamilyWinner(
        need: need,
        offers: [
          FamilyOffer(
            id: 'z-offer',
            price: 10 / 3,
            purchaseMode: PurchaseMode.weighted,
            packageQuantity:
                PackageQuantity(amount: 1, unit: MeasurementUnit.kilogram),
          ),
          FamilyOffer(
            id: 'a-offer',
            price: 5,
            purchaseMode: PurchaseMode.weighted,
            packageQuantity:
                PackageQuantity(amount: 1.5, unit: MeasurementUnit.kilogram),
          ),
        ],
      );

      expect(winner?.id, 'a-offer');
    });

  });
}
