import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/backup/presentation/data_backup_page.dart';
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
  testWidgets('export action exposes repository backup json', (tester) async {
    final repository = _FakeBackupRepository();
    String? exportedContents;

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          copyToClipboard: (_) async {},
          onExported: (contents) async {
            exportedContents = contents;
          },
        ),
      ),
    );

    await tester.tap(find.text('Export data'));
    await tester.pump();

    expect(exportedContents, repository.exportedJson);
    expect(find.text('Backup JSON copied to clipboard'), findsOneWidget);
  });

  testWidgets('import action confirms replacement before replacing data', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(repository: repository),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      repository.exportedJson,
    );

    final importButton = find.widgetWithText(FilledButton, 'Import data');
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(importButton);
    await tester.pumpAndSettle();

    expect(find.text('Replace current data?'), findsOneWidget);
    expect(repository.importedPayload, isNull);

    await tester.tap(find.text('Replace data'));
    await tester.pump();

    expect(repository.importedPayload, repository.exportedJson.trim());
    expect(find.text('Backup imported successfully'), findsOneWidget);
  });

  testWidgets('import action requires pasted json', (tester) async {
    final repository = _FakeBackupRepository();

    await tester.pumpWidget(
      MaterialApp(home: DataBackupPage(repository: repository)),
    );

    final importButton = find.widgetWithText(FilledButton, 'Import data');
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(importButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace data'));
    await tester.pump();

    expect(find.text('Paste a backup JSON before importing'), findsOneWidget);
    expect(repository.importedPayload, isNull);
  });
}

class _FakeBackupRepository implements PersistenceRepository {
  String? importedPayload;

  final String exportedJson = '''
{
  "schemaVersion": 1,
  "exportedAt": "2026-06-04T00:00:00.000Z",
  "supermarkets": [],
  "productFamilies": [],
  "catalogProducts": [],
  "priceRecords": [],
  "shoppingListEntries": []
}
''';

  @override
  Future<String> exportBackupJson() async => exportedJson;

  @override
  Future<void> importBackupJson(String jsonPayload) async {
    importedPayload = jsonPayload;
  }

  @override
  Future<int> addOrIncrementShoppingListEntry({
    required int productFamilyId,
    int quantity = 1,
  }) async =>
      1;

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
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
  Future<int?> getLastUsedSupermarketId() async => null;

  @override
  Future<List<ExternalPriceObservation>> getExternalPriceObservations() async =>
      [];

  @override
  Future<List<ExternalStoreMapping>> getExternalStoreMappings() async => [];

  @override
  Future<List<OptimizedShoppingGroup>> getOptimizedShoppingList() async => [];

  @override
  Future<List<ProductFamily>> getProductFamilies(
          {bool onlyActive = true}) async =>
      [];

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
  Future<int> resolveProductFamilyIdByName(String familyName) async => 1;

  @override
  Future<int> saveExternalPriceObservation(
    ExternalPriceObservation observation,
  ) async =>
      1;

  @override
  Future<int> saveExternalStoreMapping(ExternalStoreMapping mapping) async => 1;

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

  @override
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) async {}
}
