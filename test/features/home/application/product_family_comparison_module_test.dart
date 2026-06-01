import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/home/application/product_family_comparison_module.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  test('filters to current and active items only', () {
    final items = [
      _item(id: 1, isCurrentPrice: true, isActive: true),
      _item(id: 2, isCurrentPrice: false, isActive: true),
      _item(id: 3, isCurrentPrice: true, isActive: false),
    ];

    final view = buildProductFamilyComparisonView(
      items: items,
      supermarketById: {1: Supermarket(id: 1, name: 'A', isActive: true)},
    );

    expect(view.items.map((entry) => entry.productItem.id), [1]);
    expect(view.bestUnitPrice, 1.5);
  });

  test('sorts by unit price, price, then supermarket name', () {
    final items = [
      _item(id: 1, supermarketId: 1, price: 3.0, pricePerQuantity: 3.0),
      _item(id: 2, supermarketId: 1, price: 2.0, pricePerQuantity: 2.0),
      _item(id: 3, supermarketId: 2, price: 2.0, pricePerQuantity: 2.0),
    ];

    final view = buildProductFamilyComparisonView(
      items: items,
      supermarketById: {
        1: Supermarket(id: 1, name: 'Beta', isActive: true),
        2: Supermarket(id: 2, name: 'Alpha', isActive: true),
      },
    );

    expect(view.items.map((entry) => entry.productItem.id), [3, 2, 1]);
    expect(view.bestUnitPrice, 2.0);
  });

  test('marks rows with unknown or inactive supermarket', () {
    final items = [
      _item(id: 1, supermarketId: 1),
      _item(id: 2, supermarketId: 2),
      _item(id: 3, supermarketId: 3),
    ];

    final view = buildProductFamilyComparisonView(
      items: items,
      supermarketById: {
        1: Supermarket(id: 1, name: 'Active', isActive: true),
        2: Supermarket(id: 2, name: 'Inactive', isActive: false),
      },
    );

    expect(view.items[0].hasInactiveSupermarket, isFalse);
    expect(view.items[1].hasInactiveSupermarket, isTrue);
    expect(view.items[2].hasInactiveSupermarket, isTrue);
    expect(view.items[2].supermarketName, 'Unknown supermarket');
  });

  test('returns empty summary when no eligible items', () {
    final view = buildProductFamilyComparisonView(
      items: [_item(id: 1, isCurrentPrice: false)],
      supermarketById: {},
    );

    expect(view.items, isEmpty);
    expect(view.bestUnitPrice, isNull);
  });
}

ProductItem _item({
  required int id,
  int supermarketId = 1,
  bool isCurrentPrice = true,
  bool isActive = true,
  double price = 1.5,
  double pricePerQuantity = 1.5,
}) {
  return ProductItem(
    id: id,
    name: 'Item $id',
    isActive: isActive,
    productFamilyId: 1,
    supermarketId: supermarketId,
    price: price,
    quantity: 1,
    unitType: 'kg',
    pricePerQuantity: pricePerQuantity,
    dateAdded: DateTime(2026, 1, 1),
    isCurrentPrice: isCurrentPrice,
  );
}
