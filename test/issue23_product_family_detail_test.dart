import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/home/presentation/pages/product_families_page.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/optimized_shopping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/barcode_match_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/scanned_price_registration_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/shopping_list_optimizer.dart';
import 'package:shopping_comparation_app/features/persistence/domain/repositories/persistence_repository.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/supermarket.dart';

void main() {
  testWidgets('shows empty state when no current active Product Items', (
    tester,
  ) async {
    final repository = _FakeRepository(
      families: [const ProductFamily(id: 1, name: 'Milk')],
      supermarkets: [Supermarket(id: 1, name: 'Market A', isActive: true)],
      items: [
        ProductItem(
          id: 1,
          name: 'Whole Milk',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 1.5,
          quantity: 1,
          unitType: 'L',
          pricePerQuantity: 1.5,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: false,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(find.text('No current active Product Items'), findsOneWidget);
  });

  testWidgets('sorts comparison rows by unit price, price, supermarket', (
    tester,
  ) async {
    final repository = _FakeRepository(
      families: [const ProductFamily(id: 1, name: 'Yogurt')],
      supermarkets: [
        Supermarket(id: 1, name: 'Beta', isActive: true),
        Supermarket(id: 2, name: 'Alpha', isActive: true),
      ],
      items: [
        ProductItem(
          id: 1,
          name: 'Item C',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 3.0,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 3.0,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
        ProductItem(
          id: 2,
          name: 'Item A',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 2.0,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 2.0,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
        ProductItem(
          id: 3,
          name: 'Item B',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 2,
          price: 2.0,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 2.0,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yogurt'));
    await tester.pumpAndSettle();

    final a = tester.getTopLeft(find.text('Alpha · Item B')).dy;
    final b = tester.getTopLeft(find.text('Beta · Item A')).dy;
    final c = tester.getTopLeft(find.text('Beta · Item C')).dy;

    expect(a, lessThan(b));
    expect(b, lessThan(c));
  });

  testWidgets('two-step warning flow can be canceled with no pop', (
    tester,
  ) async {
    final repository = _FakeRepository(
      families: [const ProductFamily(id: 1, name: 'Bread')],
      supermarkets: [Supermarket(id: 1, name: 'Store', isActive: true)],
      items: [
        ProductItem(
          id: 1,
          name: 'Loaf',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 1.2,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 1.2,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bread'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete').first);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('This family has 1 active Product Items'),
      findsOneWidget,
    );

    final warningDialog = find.byType(AlertDialog).first;
    await tester.tap(
      find.descendant(
        of: warningDialog,
        matching: find.widgetWithText(FilledButton, 'Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose Product Items action'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Product family details'), findsOneWidget);
    expect(repository.savedFamilies, isEmpty);
  });

  testWidgets('shows inactive supermarket badge in comparison row', (
    tester,
  ) async {
    final repository = _FakeRepository(
      families: [const ProductFamily(id: 1, name: 'Coffee')],
      supermarkets: [Supermarket(id: 1, name: 'Store', isActive: false)],
      items: [
        ProductItem(
          id: 1,
          name: 'Ground Coffee',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 4.2,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 4.2,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coffee'));
    await tester.pumpAndSettle();

    expect(find.text('inactive supermarket'), findsOneWidget);
  });

  testWidgets('deletes product item from family details drill-down', (
    tester,
  ) async {
    final repository = _FakeRepository(
      families: [const ProductFamily(id: 1, name: 'Tea')],
      supermarkets: [Supermarket(id: 1, name: 'Store', isActive: true)],
      items: [
        ProductItem(
          id: 1,
          name: 'Green Tea',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 2.5,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 2.5,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tea'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Store · Green Tea'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    final deleteDialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(
        of: deleteDialog,
        matching: find.widgetWithText(FilledButton, 'Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.savedItems, hasLength(1));
    expect(repository.savedItems.single.isActive, isFalse);
    expect(find.text('Product family details'), findsOneWidget);
  });
}

Widget _buildApp(PersistenceRepository repository) {
  return MaterialApp(
    home: ProductFamiliesPage(
      repository: repository,
      shoppingListRepository: repository,
    ),
  );
}

class _FakeRepository implements PersistenceRepository {
  _FakeRepository({
    required this.families,
    required this.items,
    required this.supermarkets,
  });

  final List<ProductFamily> families;
  final List<ProductItem> items;
  final List<Supermarket> supermarkets;

  final List<ProductFamily> savedFamilies = [];
  final List<ProductItem> savedItems = [];

  @override
  Future<String> exportBackupJson() async => '{}';

  @override
  Future<void> importBackupJson(String jsonPayload) async {}

  @override
  Future<List<ProductFamily>> getProductFamilies({
    bool onlyActive = true,
  }) async {
    if (!onlyActive) return families;
    return families.where((f) => f.isActive).toList();
  }

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async {
    return items.where((item) {
      if (productFamilyId != null && item.productFamilyId != productFamilyId) {
        return false;
      }
      if (supermarketId != null && item.supermarketId != supermarketId) {
        return false;
      }
      if (onlyCurrentPrice && !item.isCurrentPrice) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async {
    if (!onlyActive) return supermarkets;
    return supermarkets.where((s) => s.isActive).toList();
  }

  @override
  Future<int> saveProductFamily(ProductFamily family) async {
    savedFamilies.add(family);
    return family.id ?? 1;
  }

  @override
  Future<int> saveProductItem(ProductItem item) async {
    savedItems.add(item);
    return item.id ?? 1;
  }

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async => [];

  @override
  Future<int?> getLastUsedSupermarketId() async => null;

  @override
  Future<List<ExternalStoreMapping>> getExternalStoreMappings() async => [];

  @override
  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping) async => 1;

  @override
  Future<List<ExternalPriceObservation>> getExternalPriceObservations() async =>
      [];

  @override
  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  ) async =>
      1;

  @override
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) async {}

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
  }) async =>
      1;

  @override
  Future<List<ShoppingListEntry>> getShoppingList() async => [];

  @override
  Future<List<ShoppingListEntry>> getShoppingNeedEntries() => getShoppingList();

  @override
  Future<int> resolveProductFamilyIdByName(String familyName) async => 1;

  @override
  Future<int> saveQuickProductItem({
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? purchaseMode,
    String? barcode,
  }) async =>
      1;

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) async => 1;

  @override
  Future<int> saveShoppingNeedEntry(ShoppingListEntry entry) =>
      saveShoppingListEntry(entry);

  @override
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async =>
      1;

  @override
  Future<int> addOrIncrementShoppingNeedEntry({
    required int productFamilyId,
    int quantity = 1,
  }) =>
      addOrIncrementShoppingListEntry(
        productFamilyId: productFamilyId,
        quantity: quantity,
      );

  @override
  Future<void> deleteShoppingListEntries(List<int> entryIds) async {}

  @override
  Future<void> deleteShoppingNeedEntries(List<int> entryIds) =>
      deleteShoppingListEntries(entryIds);

  @override
  Future<List<ProductFamily>> getActiveShoppingFamilies() =>
      getProductFamilies();

  @override
  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries() async =>
      const ShoppingOptimizationResult(groups: [], pendingEntries: []);

  @override
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
    String barcode,
  ) async =>
      [];

  @override
  Future<ScannedPriceRegistrationResult> registerScannedPrice({
    required String barcode,
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
  }) async =>
      const ScannedPriceRegistrationResult(created: false);

  @override
  Future<int> saveSupermarket(Supermarket supermarket) async => 1;
}
