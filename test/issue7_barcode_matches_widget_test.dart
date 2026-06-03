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
import 'package:shopping_comparation_app/features/products/data/open_food_facts_name_prefill_service.dart';
import 'package:shopping_comparation_app/features/products/data/open_prices_price_prefill_service.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocaleTestValue();
  });

  testWidgets('scan flow no-match offers Create Product Item and Re-scan', (
    tester,
  ) async {
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

  testWidgets('scan flow no-match pre-fills name from Open Food Facts', (
    tester,
  ) async {
    final repository = _FakeRepo();
    final prefillService = OpenFoodFactsNamePrefillService(
      getRequest: (_) async =>
          '{"status":1,"product":{"product_name":"Greek Yogurt 500 g","brands":"Acme","quantity":"500 g"}}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductItemsPage(
          repository: repository,
          namePrefillService: prefillService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tag));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Barcode'), 'X-NEW');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Product Item'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
    expect(find.text('Greek Yogurt 500 g'), findsOneWidget);
    expect(find.text('Greek Yogurt'), findsOneWidget);
    expect(
      find.text('Suggested from Open Food Facts. Please confirm or edit.'),
      findsOneWidget,
    );
    expect(find.text('0.5'), findsOneWidget);
  });

  testWidgets('scan flow no-match pre-fills price from Open Prices', (
    tester,
  ) async {
    final repository = _FakeRepo();
    final prefillService = OpenFoodFactsNamePrefillService(
      getRequest: (_) async =>
          '{"status":1,"product":{"product_name":"Greek Yogurt 500 g","brands":"Acme","quantity":"500 g"}}',
    );
    final pricePrefillService = OpenPricesPricePrefillService(
      getRequest: (_) async =>
          '{"items":[{"price":0.99,"currency":"EUR","date":"2026-04-07","location":{"osm_display_name":"Olot"}}]}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductItemsPage(
          repository: repository,
          namePrefillService: prefillService,
          pricePrefillService: pricePrefillService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tag));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Barcode'), 'X-NEW');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Product Item'));
    await tester.pumpAndSettle();

    expect(find.text('0.99'), findsOneWidget);
  });

  testWidgets('scan flow prefers system locale for Open Food Facts name', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('ca');

    final repository = _FakeRepo();
    final prefillService = OpenFoodFactsNamePrefillService(
      getRequest: (_) async =>
          '{"status":1,"product":{"product_name":"Paahdettu maap\u00e4hkin\u00e4","product_name_ca":"Cacauets pelats fregits sense sal","brands":"Alesto","quantity":"200 g"}}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductItemsPage(
          repository: repository,
          namePrefillService: prefillService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tag));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Barcode'), '20615420');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Product Item'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cacauets pelats fregits sense sal'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Paahdettu maapähkinä'), findsNothing);
  });

  testWidgets('existing family prefill does not show OFF helper text', (
    tester,
  ) async {
    final repository = _FakeRepo(
      matchesByBarcode: {
        'X-KNOWN': [
          BarcodeMatchResult(
            productItem: ProductItem(
              id: 10,
              name: 'Known Yogurt',
              productFamilyId: 1,
              supermarketId: 1,
              price: 2,
              quantity: 1,
              unitType: 'kg',
              pricePerQuantity: 2,
              dateAdded: DateTime(2026, 1, 1),
              barcode: 'X-KNOWN',
            ),
            familyName: 'Confirmed Family',
            supermarketName: 'A',
          ),
        ],
      },
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductItemsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tag));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Barcode'),
      'X-KNOWN',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Product Item'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmed Family'), findsOneWidget);
    expect(
      find.text('Suggested from Open Food Facts. Please confirm or edit.'),
      findsNothing,
    );
  });

  testWidgets('invalid scanned item does not resolve or save family first', (
    tester,
  ) async {
    final repository = _FakeRepo(
      families: const [
        ProductFamily(id: 2, name: 'Milk', shoppingUnit: 'liter'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductItemsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tag));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Barcode'), 'X-NEW');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Product Item'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Family'), 'Milk');
    await tester.enterText(find.widgetWithText(TextField, 'Price'), '2.5');
    await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '6');
    await tester.tap(find.text('kg').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('unit').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.resolveCalls, 0);
    expect(repository.registerScannedPriceCalls, 0);
  });
}

class _FakeRepo implements PersistenceRepository {
  _FakeRepo({
    this.matchesByBarcode = const {},
    this.families = const [ProductFamily(id: 1, name: 'Milk')],
  });

  final Map<String, List<BarcodeMatchResult>> matchesByBarcode;
  final List<ProductFamily> families;
  int resolveCalls = 0;
  int registerScannedPriceCalls = 0;

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
      matchesByBarcode[barcode] ?? [];

  @override
  Future<int?> getLastUsedSupermarketId() async => 1;

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async => [];

  @override
  Future<List<ProductFamily>> getProductFamilies({
    bool onlyActive = true,
  }) async =>
      families;

  @override
  Future<List<ProductItem>> getProductItems({
    int? productFamilyId,
    int? supermarketId,
    bool onlyCurrentPrice = true,
  }) async =>
      [];

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
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async => [
        Supermarket(id: 1, name: 'A'),
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
  }) async {
    registerScannedPriceCalls += 1;
    return const ScannedPriceRegistrationResult(created: false);
  }

  @override
  Future<int> resolveProductFamilyIdByName(String familyName) async {
    resolveCalls += 1;
    return 1;
  }

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
  }) async =>
      1;

  @override
  Future<int> saveShoppingListEntry(ShoppingListEntry entry) async => 1;

  @override
  Future<int> saveSupermarket(Supermarket supermarket) async => 1;
}
