import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/home/presentation/model_records_pages.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/barcode_match_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/optimized_shopping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/scanned_price_registration_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/repositories/persistence_repository.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  testWidgets('fresh capture uses weighted semantics by default for kg items', (
    tester,
  ) async {
    final repository = _CapturingRepo();

    await tester.pumpWidget(
      MaterialApp(home: ProductItemsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Fresh'));
    await tester.pumpAndSettle();

    expect(find.text('Add fresh product'), findsOneWidget);
    expect(
      find.widgetWithText(SwitchListTile, 'Fresh product'),
      findsOneWidget,
    );

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Tomatoes');
    await tester.enterText(
      find.widgetWithText(TextField, 'Family'),
      'Tomatoes',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Price'), '2.75');
    await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '1.1');

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.lastQuickCapture, isNotNull);
    expect(repository.lastQuickCapture!.barcode, isNull);
    expect(repository.lastQuickCapture!.purchaseMode, 'weighted');
    expect(repository.lastQuickCapture!.unitType, 'kg');
  });
}

class _QuickCaptureCall {
  const _QuickCaptureCall({
    required this.productName,
    required this.familyName,
    required this.supermarketId,
    required this.price,
    required this.quantity,
    required this.unitType,
    required this.purchaseMode,
    required this.barcode,
  });

  final String productName;
  final String familyName;
  final int supermarketId;
  final double price;
  final double quantity;
  final String unitType;
  final String? purchaseMode;
  final String? barcode;
}

class _CapturingRepo implements PersistenceRepository {
  _QuickCaptureCall? lastQuickCapture;

  @override
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async => 1;

  @override
  Future<void> deleteShoppingListEntries(List<int> entryIds) async {}

  @override
  Future<List<BarcodeMatchResult>> findCurrentActiveByBarcode(
    String barcode,
  ) async => [];

  @override
  Future<int?> getLastUsedSupermarketId() async => 1;

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async => [];

  @override
  Future<List<ProductFamily>> getProductFamilies({
    bool onlyActive = true,
  }) async => const [];

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async => [];

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
  ) async => 1;

  @override
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) async {}

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
  }) async => 1;

  @override
  Future<List<ShoppingListEntry>> getShoppingList() async => [];

  @override
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async => [
    Supermarket(id: 1, name: 'Market'),
  ];

  @override
  Future<ScannedPriceRegistrationResult> registerScannedPrice({
    required String barcode,
    required String productName,
    required String familyName,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
  }) async => const ScannedPriceRegistrationResult(created: false);

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
    String? purchaseMode,
    String? barcode,
  }) async {
    lastQuickCapture = _QuickCaptureCall(
      productName: productName,
      familyName: familyName,
      supermarketId: supermarketId,
      price: price,
      quantity: quantity,
      unitType: unitType,
      purchaseMode: purchaseMode,
      barcode: barcode,
    );
    return 1;
  }

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) async => 1;

  @override
  Future<int> saveSupermarket(Supermarket supermarket) async => 1;
}
