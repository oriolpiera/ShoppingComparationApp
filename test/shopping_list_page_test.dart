import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/home/presentation/pages/shopping_list_page.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/repositories/shopping_list_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/shopping_list_optimizer.dart';

void main() {
  testWidgets('shows grouped shopping needs and pending inactive families', (
    tester,
  ) async {
    final repository = _FakeShoppingListRepository(
      optimization: ShoppingOptimizationResult(
        groups: [
          ShoppingOptimizationGroup(
            supermarketId: 1,
            supermarketName: 'Alpha Market',
            entries: [
              ShoppingOptimizationResolvedEntry(
                shoppingListEntryId: 10,
                productFamilyId: 1,
                productFamilyName: 'Milk',
                quantity: 2,
                bestItem: _item(
                  id: 100,
                  familyId: 1,
                  supermarketId: 1,
                  name: 'Whole Milk',
                  pricePerQuantity: 1.50,
                  price: 1.50,
                ),
                estimatedCost: 3,
              ),
            ],
          ),
        ],
        pendingEntries: const [
          ShoppingOptimizationPendingEntry(
            shoppingListEntryId: 11,
            productFamilyId: 2,
            productFamilyName: 'Bread',
            quantity: 1,
            isInactiveFamily: true,
          ),
        ],
      ),
      activeFamilies: const [ProductFamily(id: 1, name: 'Milk')],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Alpha Market'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.textContaining('Whole Milk'), findsOneWidget);
    expect(find.text('Pending / inactive'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);
    expect(find.text('Inactive family'), findsOneWidget);
  });

  testWidgets('updates quantity through shopping need seam', (tester) async {
    final repository = _FakeShoppingListRepository(
      optimization: ShoppingOptimizationResult(
        groups: [
          ShoppingOptimizationGroup(
            supermarketId: 1,
            supermarketName: 'Alpha Market',
            entries: [
              ShoppingOptimizationResolvedEntry(
                shoppingListEntryId: 10,
                productFamilyId: 1,
                productFamilyName: 'Milk',
                quantity: 2,
                bestItem: _item(
                  id: 100,
                  familyId: 1,
                  supermarketId: 1,
                  name: 'Whole Milk',
                  pricePerQuantity: 1.50,
                  price: 1.50,
                ),
                estimatedCost: 3,
              ),
            ],
          ),
        ],
        pendingEntries: const [],
      ),
      activeFamilies: const [ProductFamily(id: 1, name: 'Milk')],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.add).first);
    await tester.pumpAndSettle();

    expect(repository.savedEntries, hasLength(1));
    expect(
      repository.savedEntries.single,
      isA<ShoppingListEntry>()
          .having((entry) => entry.id, 'id', 10)
          .having((entry) => entry.productFamilyId, 'family', 1)
          .having((entry) => entry.quantity, 'quantity', 3),
    );
  });

  testWidgets('adds and deletes shopping needs through narrow repository', (
    tester,
  ) async {
    final repository = _FakeShoppingListRepository(
      optimization: ShoppingOptimizationResult(
        groups: [
          ShoppingOptimizationGroup(
            supermarketId: 1,
            supermarketName: 'Alpha Market',
            entries: [
              ShoppingOptimizationResolvedEntry(
                shoppingListEntryId: 10,
                productFamilyId: 1,
                productFamilyName: 'Milk',
                quantity: 2,
                bestItem: _item(
                  id: 100,
                  familyId: 1,
                  supermarketId: 1,
                  name: 'Whole Milk',
                  pricePerQuantity: 1.50,
                  price: 1.50,
                ),
                estimatedCost: 3,
              ),
            ],
          ),
        ],
        pendingEntries: const [],
      ),
      activeFamilies: const [
        ProductFamily(id: 1, name: 'Milk'),
        ProductFamily(id: 2, name: 'Bread'),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '4');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(repository.addCalls, hasLength(1));
    expect(repository.addCalls.single.productFamilyId, 2);
    expect(repository.addCalls.single.quantity, 4);

    await tester.longPress(find.text('Milk'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.deletedEntryIds, containsAll(<int>[10]));
  });
}

MaterialApp _buildApp(ShoppingListRepository repository) {
  return MaterialApp(home: ShoppingListPage(repository: repository));
}

ProductItem _item({
  required int id,
  required int familyId,
  required int supermarketId,
  required String name,
  required double price,
  required double pricePerQuantity,
}) {
  return ProductItem(
    id: id,
    name: name,
    isActive: true,
    productFamilyId: familyId,
    supermarketId: supermarketId,
    price: price,
    quantity: 1,
    unitType: 'L',
    pricePerQuantity: pricePerQuantity,
    dateAdded: DateTime(2026, 1, 1),
    isCurrentPrice: true,
  );
}

class _FakeShoppingListRepository implements ShoppingListRepository {
  _FakeShoppingListRepository({
    required this.optimization,
    required this.activeFamilies,
  });

  final ShoppingOptimizationResult optimization;
  final List<ProductFamily> activeFamilies;

  final List<ShoppingListEntry> savedEntries = [];
  final List<_AddCall> addCalls = [];
  final List<int> deletedEntryIds = [];

  @override
  Future<int> addOrIncrementShoppingNeedEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async {
    addCalls.add(
      _AddCall(productFamilyId: productFamilyId, quantity: quantity),
    );
    return 1;
  }

  @override
  Future<void> deleteShoppingNeedEntries(List<int> entryIds) async {
    deletedEntryIds.addAll(entryIds);
  }

  @override
  Future<List<ProductFamily>> getActiveShoppingFamilies() async =>
      activeFamilies;

  @override
  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries() async =>
      optimization;

  @override
  Future<List<ShoppingListEntry>> getShoppingNeedEntries() async => [];

  @override
  Future<int> saveShoppingNeedEntry(ShoppingListEntry entry) async {
    savedEntries.add(entry);
    return entry.id ?? 1;
  }
}

class _AddCall {
  const _AddCall({required this.productFamilyId, required this.quantity});

  final int productFamilyId;
  final int quantity;
}
