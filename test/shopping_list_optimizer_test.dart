import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/shopping_list_optimizer.dart';

void main() {
  group('isBetterOptimizedItem', () {
    test('prefers lower price per quantity', () {
      final current = _item(
        id: 2,
        familyId: 1,
        marketId: 1,
        price: 3,
        ppq: 1.5,
        date: DateTime(2026, 1, 1),
      );
      final candidate = _item(
        id: 3,
        familyId: 1,
        marketId: 2,
        price: 4,
        ppq: 1.2,
        date: DateTime(2026, 1, 2),
      );

      expect(isBetterOptimizedItem(candidate, current), isTrue);
    });

    test('uses lower absolute price as second tiebreak', () {
      final current = _item(
        id: 2,
        familyId: 1,
        marketId: 1,
        price: 2.2,
        ppq: 1.0,
        date: DateTime(2026, 1, 1),
      );
      final candidate = _item(
        id: 3,
        familyId: 1,
        marketId: 2,
        price: 2.1,
        ppq: 1.0,
        date: DateTime(2026, 1, 1),
      );

      expect(isBetterOptimizedItem(candidate, current), isTrue);
    });

    test('uses most recent date as third tiebreak', () {
      final current = _item(
        id: 2,
        familyId: 1,
        marketId: 1,
        price: 2.0,
        ppq: 1.0,
        date: DateTime(2026, 1, 1),
      );
      final candidate = _item(
        id: 3,
        familyId: 1,
        marketId: 2,
        price: 2.0,
        ppq: 1.0,
        date: DateTime(2026, 1, 2),
      );

      expect(isBetterOptimizedItem(candidate, current), isTrue);
    });

    test('uses lower id as final tiebreak', () {
      final current = _item(
        id: 7,
        familyId: 1,
        marketId: 1,
        price: 2.0,
        ppq: 1.0,
        date: DateTime(2026, 1, 2),
      );
      final candidate = _item(
        id: 6,
        familyId: 1,
        marketId: 2,
        price: 2.0,
        ppq: 1.0,
        date: DateTime(2026, 1, 2),
      );

      expect(isBetterOptimizedItem(candidate, current), isTrue);
    });
  });

  group('optimizeShoppingList', () {
    test('groups optimized rows and keeps pending rows behavior', () {
      final result = optimizeShoppingList(
        shoppingList: const [
          ShoppingListEntry(id: 10, productFamilyId: 1, quantity: 2),
          ShoppingListEntry(id: 11, productFamilyId: 2, quantity: 1),
          ShoppingListEntry(id: 12, productFamilyId: 3, quantity: 4),
          ShoppingListEntry(id: 13, productFamilyId: 4, quantity: 1),
          ShoppingListEntry(id: 14, productFamilyId: 999, quantity: 1),
        ],
        familyById: const {
          1: ProductFamily(id: 1, name: 'Milk', isActive: true),
          2: ProductFamily(
            id: 2,
            name: 'Bread',
            isActive: true,
            shoppingUnit: 'kilogram',
            purchaseMode: 'weighted',
          ),
          3: ProductFamily(id: 3, name: 'Cheese', isActive: false),
          4: ProductFamily(id: 4, name: 'Eggs', isActive: true),
        },
        supermarketNameById: const {1: 'Zeta Market', 2: 'Alpha Market'},
        items: [
          _item(
            id: 2,
            familyId: 1,
            marketId: 1,
            price: 3.0,
            ppq: 1.5,
            date: DateTime(2026, 1, 1),
          ),
          _item(
            id: 1,
            familyId: 1,
            marketId: 2,
            price: 2.0,
            ppq: 1.0,
            date: DateTime(2026, 1, 2),
          ),
          _item(
            id: 3,
            familyId: 2,
            marketId: 2,
            price: 2.5,
            ppq: 1.1,
            quantity: 1,
            date: DateTime(2026, 1, 2),
          ),
          _item(
            id: 4,
            familyId: 3,
            marketId: 2,
            price: 2.5,
            ppq: 1.1,
            date: DateTime(2026, 1, 2),
          ),
          _item(
            id: 5,
            familyId: 4,
            marketId: 999,
            price: 4.0,
            ppq: 2.0,
            date: DateTime(2026, 1, 2),
          ),
        ],
      );

      expect(result.groups.map((g) => g.supermarketName), ['Alpha Market']);
      expect(result.groups.single.entries.map((e) => e.productFamilyId), [
        1,
        2,
      ]);
      expect(
        result.groups.single.entries
            .firstWhere((e) => e.productFamilyId == 2)
            .estimatedCost,
        2.5,
      );

      expect(result.pendingEntries.map((e) => e.productFamilyId), [3, 4]);
      expect(
        result.pendingEntries
            .firstWhere((e) => e.productFamilyId == 3)
            .isInactiveFamily,
        isTrue,
      );
      expect(
        result.pendingEntries
            .firstWhere((e) => e.productFamilyId == 4)
            .isInactiveFamily,
        isFalse,
      );
    });

    test(
      'chooses cheapest whole-package purchase instead of lowest unit price',
      () {
        final result = optimizeShoppingList(
          shoppingList: const [
            ShoppingListEntry(id: 20, productFamilyId: 1, quantity: 1),
          ],
          familyById: const {
            1: ProductFamily(
              id: 1,
              name: 'Juice',
              shoppingUnit: 'liter',
              purchaseMode: 'packaged',
            ),
          },
          supermarketNameById: const {1: 'Alpha Market', 2: 'Beta Market'},
          items: [
            _item(
              id: 1,
              familyId: 1,
              marketId: 1,
              price: 1.2,
              ppq: 1.71,
              quantity: 700,
              unitType: 'ml',
              packageQuantityAmount: 700,
              packageQuantityUnit: 'ml',
              normalizedMeasurementUnit: 'ml',
              date: DateTime(2026, 1, 1),
            ),
            _item(
              id: 2,
              familyId: 1,
              marketId: 2,
              price: 1.1,
              ppq: 2.2,
              quantity: 500,
              unitType: 'ml',
              packageQuantityAmount: 500,
              packageQuantityUnit: 'ml',
              normalizedMeasurementUnit: 'ml',
              date: DateTime(2026, 1, 2),
            ),
          ],
        );

        final selected = result.groups.single.entries.single;
        expect(selected.bestItem.id, 2);
        expect(selected.estimatedCost, 2.2);
      },
    );

    test('marks family as pending when candidate units are incompatible', () {
      final result = optimizeShoppingList(
        shoppingList: const [
          ShoppingListEntry(id: 21, productFamilyId: 1, quantity: 1),
        ],
        familyById: const {
          1: ProductFamily(
            id: 1,
            name: 'Rice',
            shoppingUnit: 'kilogram',
            purchaseMode: 'packaged',
          ),
        },
        supermarketNameById: const {1: 'Alpha Market'},
        items: [
          _item(
            id: 1,
            familyId: 1,
            marketId: 1,
            price: 1,
            ppq: 1,
            quantity: 1,
            unitType: 'L',
            packageQuantityAmount: 1,
            packageQuantityUnit: 'L',
            normalizedMeasurementUnit: 'l',
            date: DateTime(2026, 1, 1),
          ),
        ],
      );

      expect(result.groups, isEmpty);
      expect(result.pendingEntries.map((e) => e.productFamilyId), [1]);
    });
  });
}

ProductItem _item({
  required int id,
  required int familyId,
  required int marketId,
  required double price,
  required double ppq,
  double quantity = 1,
  String unitType = 'kg',
  double? packageQuantityAmount,
  String? packageQuantityUnit,
  String? normalizedMeasurementUnit,
  required DateTime date,
}) {
  return ProductItem(
    id: id,
    name: 'item-$id',
    productFamilyId: familyId,
    supermarketId: marketId,
    price: price,
    quantity: quantity,
    unitType: unitType,
    pricePerQuantity: ppq,
    dateAdded: date,
    packageQuantityAmount: packageQuantityAmount,
    packageQuantityUnit: packageQuantityUnit,
    normalizedMeasurementUnit: normalizedMeasurementUnit,
  );
}
