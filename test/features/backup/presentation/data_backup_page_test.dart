import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/backup/application/backup_import_service.dart';
import 'package:shopping_comparation_app/features/backup/application/backup_share_service.dart';
import 'package:shopping_comparation_app/features/backup/presentation/data_backup_page.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/barcode_match_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/optimized_shopping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/scanned_price_registration_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/shopping_list_optimizer.dart';
import 'package:shopping_comparation_app/features/persistence/domain/repositories/persistence_repository.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  testWidgets('shareAction_invokesOnSharePressedWithRepositoryJson', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();
    String? sharedJson;

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onSharePressed: (json) async {
            sharedJson = json;
          },
        ),
      ),
    );

    await tester.tap(find.text('Share backup file'));
    await tester.pump();

    expect(sharedJson, repository.exportedJson);
  });

  testWidgets('shareAction_showsShareReadySnackbarOnSuccess', (tester) async {
    final repository = _FakeBackupRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onSharePressed: (_) async {},
        ),
      ),
    );

    await tester.tap(find.text('Share backup file'));
    await tester.pump();

    expect(find.text('Backup file ready to share'), findsOneWidget);
  });

  testWidgets('shareAction_stillInvokesOnExportedOnSuccess', (tester) async {
    final repository = _FakeBackupRepository();
    String? exportedContents;

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onSharePressed: (_) async {},
          onExported: (contents) async {
            exportedContents = contents;
          },
        ),
      ),
    );

    await tester.tap(find.text('Share backup file'));
    await tester.pump();

    expect(exportedContents, repository.exportedJson);
  });

  testWidgets('shareAction_showsFailureSnackbarWhenOnSharePressedThrows', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();
    const userMessage = 'Could not share the backup file. Please try again.';

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onSharePressed: (_) async {
            throw BackupShareException(userMessage);
          },
        ),
      ),
    );

    await tester.tap(find.text('Share backup file'));
    await tester.pump();

    expect(find.text(userMessage), findsOneWidget);
  });

  testWidgets('shareAction_doesNotInvokeOnExportedOnFailure', (tester) async {
    final repository = _FakeBackupRepository();
    var exportedCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onSharePressed: (_) async {
            throw BackupShareException('boom');
          },
          onExported: (_) async {
            exportedCalls += 1;
          },
        ),
      ),
    );

    await tester.tap(find.text('Share backup file'));
    await tester.pump();

    expect(exportedCalls, 0);
  });

  testWidgets('shareAction_disablesButtonsWhileInFlight', (tester) async {
    final completer = Completer<void>();
    final repository = _FakeBackupRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onSharePressed: (_) => completer.future,
        ),
      ),
    );

    await tester.tap(find.text('Share backup file'));
    await tester.pump();

    // While the share future is pending, both buttons must be disabled.
    final inFlightShare = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Share backup file'),
    );
    final inFlightCopy = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Copy JSON to clipboard'),
    );
    expect(inFlightShare.onPressed, isNull);
    expect(inFlightCopy.onPressed, isNull);

    // Resolve and let the busy state clear.
    completer.complete();
    await tester.pumpAndSettle();

    final afterShare = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Share backup file'),
    );
    final afterCopy = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Copy JSON to clipboard'),
    );
    expect(afterShare.onPressed, isNotNull);
    expect(afterCopy.onPressed, isNotNull);
  });

  testWidgets('copyJsonAction_stillCopiesToClipboardViaInjectedCallback', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();
    String? exportedContents;
    String? copiedContents;

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          copyToClipboard: (json) async {
            copiedContents = json;
          },
          onExported: (contents) async {
            exportedContents = contents;
          },
        ),
      ),
    );

    await tester.tap(find.text('Copy JSON to clipboard'));
    await tester.pump();

    expect(copiedContents, repository.exportedJson);
    expect(exportedContents, repository.exportedJson);
    expect(find.text('Backup JSON copied to clipboard'), findsOneWidget);
  });

  testWidgets('copyJsonAction_stillCopiesToClipboardViaDefaultImplementation', (
    tester,
  ) async {
    // Swap the page's default clipboard impl for a test double so we don't
    // need to mock the `flutter/platform` channel (which the test binding
    // shares with the framework's own Title / SystemChrome calls).
    final originalDefault = DataBackupPage.defaultCopyToClipboard;
    String? captured;
    DataBackupPage.defaultCopyToClipboard = (json) async {
      captured = json;
    };
    addTearDown(() {
      DataBackupPage.defaultCopyToClipboard = originalDefault;
    });

    final repository = _FakeBackupRepository();

    await tester
        .pumpWidget(MaterialApp(home: DataBackupPage(repository: repository)));

    await tester.tap(find.text('Copy JSON to clipboard'));
    await tester.pump();

    expect(captured, repository.exportedJson);
    expect(find.text('Backup JSON copied to clipboard'), findsOneWidget);
  });

  testWidgets('importAction_confirmsReplacementBeforeReplacingData', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();

    await tester.pumpWidget(
      MaterialApp(home: DataBackupPage(repository: repository)),
    );

    await tester.enterText(find.byType(TextField), repository.exportedJson);

    final importButton = find.widgetWithText(FilledButton, 'Import data');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    await tester.tap(importButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Replace current data?'), findsOneWidget);
    expect(repository.importedPayload, isNull);

    await tester.tap(find.text('Replace data'));
    await tester.pump();

    expect(repository.importedPayload, repository.exportedJson.trim());
    expect(find.text('Backup imported successfully'), findsOneWidget);
  });

  testWidgets('importAction_requiresPastedJson', (tester) async {
    final repository = _FakeBackupRepository();

    await tester
        .pumpWidget(MaterialApp(home: DataBackupPage(repository: repository)));

    final importButton = find.widgetWithText(FilledButton, 'Import data');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    await tester.tap(importButton, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace data'));
    await tester.pump();

    expect(find.text('Paste a backup JSON before importing'), findsOneWidget);
    expect(repository.importedPayload, isNull);
  });

  testWidgets('pickFileAction_invokesOnPickFilePressed', (tester) async {
    final repository = _FakeBackupRepository();
    var pickCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onPickFilePressed: () async {
            pickCalls += 1;
            return null;
          },
        ),
      ),
    );

    await tester.tap(find.text('Pick backup file'));
    await tester.pump();

    expect(pickCalls, 1);
    expect(repository.importedPayload, isNull);
  });

  testWidgets('pickFileAction_passesJsonToRepositoryAfterConfirmation', (
    tester,
  ) async {
    final repository = _FakeBackupRepository();
    const pickedJson = '''
{
  "schemaVersion": 1,
  "exportedAt": "2026-06-05T00:00:00.000Z",
  "supermarkets": [],
  "productFamilies": [],
  "catalogProducts": [],
  "priceRecords": [],
  "shoppingListEntries": []
}
''';

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onPickFilePressed: () async => pickedJson,
        ),
      ),
    );

    await tester.tap(find.text('Pick backup file'));
    await tester.pumpAndSettle();

    expect(find.text('Replace current data?'), findsOneWidget);
    expect(repository.importedPayload, isNull);

    await tester.tap(find.text('Replace data'));
    await tester.pump();

    expect(repository.importedPayload, pickedJson);
    expect(find.text('Backup imported successfully'), findsOneWidget);
  });

  testWidgets('pickFileAction_isNoOpWhenPickerReturnsNull', (tester) async {
    final repository = _FakeBackupRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onPickFilePressed: () async => null,
        ),
      ),
    );

    await tester.tap(find.text('Pick backup file'));
    await tester.pumpAndSettle();

    expect(find.text('Replace current data?'), findsNothing);
    expect(repository.importedPayload, isNull);
  });

  testWidgets('pickFileAction_doesNotImportOnPickCancellation', (tester) async {
    final repository = _FakeBackupRepository();
    String? modalWasShown;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataBackupPage(
            repository: repository,
            onPickFilePressed: () async {
              modalWasShown = 'picker_called';
              return null;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pick backup file'));
    await tester.pumpAndSettle();

    expect(modalWasShown, 'picker_called');
    expect(repository.importedPayload, isNull);
    expect(find.text('Replace current data?'), findsNothing);
  });

  testWidgets('pickFileAction_showsSnackbarOnPickError', (tester) async {
    final repository = _FakeBackupRepository();
    const userMessage = 'Could not read the selected backup file. Try again.';

    await tester.pumpWidget(
      MaterialApp(
        home: DataBackupPage(
          repository: repository,
          onPickFilePressed: () async {
            throw BackupImportException(userMessage);
          },
        ),
      ),
    );

    await tester.tap(find.text('Pick backup file'));
    await tester.pump();

    expect(find.text(userMessage), findsOneWidget);
    expect(repository.importedPayload, isNull);
  });

  testWidgets(
    'pickFileAction_overwritesTextareaWithPickedContent',
    (tester) async {
      final repository = _FakeBackupRepository();
      const typed = 'I was typed by the user';
      const picked = '{"schemaVersion":1}';

      await tester.pumpWidget(
        MaterialApp(
          home: DataBackupPage(
            repository: repository,
            onPickFilePressed: () async => picked,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), typed);

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();
      await tester.tap(find.text('Pick backup file'), warnIfMissed: false);
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, picked);

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(repository.importedPayload, isNull);
      expect(field.controller?.text, picked);
    },
  );
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
  Future<int> addOrIncrementShoppingNeedEntry({
    required int productFamilyId,
    int quantity = 1,
  }) =>
      addOrIncrementShoppingListEntry(
        productFamilyId: productFamilyId,
        quantity: quantity,
      );

  @override
  Future<int> confirmExternalObservationLocally({
    required int observationId,
  }) async =>
      1;

  @override
  Future<void> deleteShoppingListEntries(List<int> entryIds) async {}

  @override
  Future<void> deleteShoppingNeedEntries(List<int> entryIds) =>
      deleteShoppingListEntries(entryIds);

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
  Future<List<ProductFamily>> getActiveShoppingFamilies() =>
      getProductFamilies();

  @override
  Future<ShoppingOptimizationResult> getOptimizedShoppingNeedEntries() async =>
      const ShoppingOptimizationResult(groups: [], pendingEntries: []);

  @override
  Future<List<ProductFamily>> getProductFamilies({
    bool onlyActive = true,
  }) async =>
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
  Future<List<ShoppingListEntry>> getShoppingNeedEntries() => getShoppingList();

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
  Future<int> saveShoppingNeedEntry(ShoppingListEntry entry) =>
      saveShoppingListEntry(entry);

  @override
  Future<int> saveSupermarket(Supermarket supermarket) async => 1;

  @override
  Future<void> updateExternalObservationReviewStatus({
    required int observationId,
    required ExternalObservationReviewStatus newStatus,
  }) async {}
}
