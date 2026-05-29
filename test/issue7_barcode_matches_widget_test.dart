import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/home/presentation/model_records_pages.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/barcode_match_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/optimized_shopping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/scanned_price_registration_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/repositories/persistence_repository.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  testWidgets('scan flow no-match offers Create Product Item and Re-scan',
      (tester) async {
    final repository = _FakeRepo();

    await tester.pumpWidget(
      MaterialApp(home: ProductItemsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tag));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Barcode'), 'X-NEW');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    expect(find.text('Create Product Item'), findsOneWidget);
    expect(find.text('Re-scan'), findsAtLeastNWidgets(1));
  });
}

class _FakeRepo implements PersistenceRepository {
  @override
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async =>
      1;

  @override
  Future<void> deleteShoppingListEntries(List<int> entryIds) async {}

  @override
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
    String barcode,
  ) async =>
      [];

  @override
  Future<int?> getLastUsedSupermarketId() async => 1;

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async => [];

  @override
  Future<List<ProductFamily>> getProductFamilies(
          {bool onlyActive = true}) async =>
      [const ProductFamily(id: 1, name: 'Milk')];

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async =>
      [];

  @override
  Future<List<ShoppingListEntry>> getShoppingList() async => [];

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async =>
      [Supermarket(id: 1, name: 'A')];

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
  Future<int> resolveProductFamilyIdByName(String familyName) async => 1;

  @override
  Future<int> saveProductFamily(ProductFamily family) async => 1;

  @override
  Future<int> saveProductItem(ProductItem item) async => 1;

  @override
  Future<int> saveQuickProductItem({
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    String? barcode,
  }) async =>
      1;

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) async => 1;

  @override
  Future<int> saveSupermarket(Supermarket supermarket) async => 1;
}
