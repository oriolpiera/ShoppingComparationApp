import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/home/application/product_family_details_controller.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_family.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/product_item.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/barcode_match_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_price_observation.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/external_store_mapping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/optimized_shopping.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/scanned_price_registration_result.dart';
import 'package:shopping_comparation_app/features/persistence/domain/shopping_list_optimizer.dart';
import 'package:shopping_comparation_app/features/persistence/domain/entities/shopping_list_entry.dart';
import 'package:shopping_comparation_app/features/persistence/domain/repositories/persistence_repository.dart';
import 'package:shopping_comparation_app/features/supermarkets/data/models/supermarket.dart';

void main() {
  group('loadData', () {
    test('returns empty data when family has no id', () async {
      final controller = ProductFamilyDetailsController(
        repository: _FakeRepository(items: [], supermarkets: []),
        family: const ProductFamily(name: 'No ID family'),
      );

      final data = await controller.loadData();

      expect(data.items, isEmpty);
      expect(data.supermarketById, isEmpty);
      expect(data.activeItemCount, 0);
    });

    test('loads items and supermarkets and computes active count', () async {
      final items = [
        ProductItem(
          id: 1,
          name: 'Active',
          isActive: true,
          productFamilyId: 1,
          supermarketId: 1,
          price: 1.0,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 1.0,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
        ProductItem(
          id: 2,
          name: 'Inactive',
          isActive: false,
          productFamilyId: 1,
          supermarketId: 1,
          price: 2.0,
          quantity: 1,
          unitType: 'kg',
          pricePerQuantity: 2.0,
          dateAdded: DateTime(2026, 1, 1),
          isCurrentPrice: true,
        ),
      ];
      final supermarkets = [
        Supermarket(id: 1, name: 'Market', isActive: true),
        Supermarket(id: 2, name: 'Inactive', isActive: false),
      ];

      final controller = ProductFamilyDetailsController(
        repository: _FakeRepository(
          families: [const ProductFamily(id: 1, name: 'Test')],
          items: items,
          supermarkets: supermarkets,
        ),
        family: const ProductFamily(id: 1, name: 'Test'),
      );

      final data = await controller.loadData();

      expect(data.items, hasLength(2));
      expect(data.supermarketById, hasLength(2));
      expect(data.supermarketById[1]!.name, 'Market');
      expect(data.activeItemCount, 1);
    });
  });

  group('saveEditedItem', () {
    test('returns error when item semantics are invalid', () async {
      final repository = _FakeRepository(items: [], supermarkets: []);
      final controller = ProductFamilyDetailsController(
        repository: repository,
        family: const ProductFamily(
          id: 1,
          name: 'Test',
          shoppingUnit: 'piece',
          purchaseMode: 'packaged',
        ),
      );

      final error = await controller.saveEditedItem(
        original: _anyItem(),
        name: 'Item',
        price: 5.0,
        quantity: 1,
        unitType: 'kg',
      );

      expect(error, isNotNull);
      expect(error, contains('incompatible'));
      expect(repository.savedItems, isEmpty);
    });

    test('saves item with derived fields on valid input', () async {
      final savedItems = <ProductItem>[];
      final repository = _FakeRepository(
        items: [],
        supermarkets: [],
        onSaveItem: (item) {
          savedItems.add(item);
        },
      );
      final controller = ProductFamilyDetailsController(
        repository: repository,
        family: const ProductFamily(id: 1, name: 'Test'),
      );

      final error = await controller.saveEditedItem(
        original: _anyItem(),
        name: 'Edited Item',
        price: 3.5,
        quantity: 2,
        unitType: 'kg',
      );

      expect(error, isNull);
      expect(savedItems, hasLength(1));
      final saved = savedItems.single;
      expect(saved.name, 'Edited Item');
      expect(saved.price, 3.5);
      expect(saved.quantity, 2);
      expect(saved.unitType, 'kg');
      expect(saved.pricePerQuantity, 1.75);
      expect(saved.packageQuantityAmount, 2);
      expect(saved.packageQuantityUnit, 'kg');
      expect(saved.normalizedMeasurementUnit, 'kg');
      expect(saved.isActive, true);
    });
  });

  group('inactivateItem', () {
    test('saves item with isActive=false', () async {
      final savedItems = <ProductItem>[];
      final repository = _FakeRepository(
        items: [],
        supermarkets: [],
        onSaveItem: (item) {
          savedItems.add(item);
        },
      );
      final controller = ProductFamilyDetailsController(
        repository: repository,
        family: const ProductFamily(id: 1, name: 'Test'),
      );

      await controller.inactivateItem(_anyItem());

      expect(savedItems, hasLength(1));
      expect(savedItems.single.isActive, false);
      expect(savedItems.single.id, 1);
    });
  });
}

ProductItem _anyItem() {
  return ProductItem(
    id: 1,
    name: 'Original',
    isActive: true,
    productFamilyId: 1,
    supermarketId: 1,
    price: 2.0,
    quantity: 1,
    unitType: 'kg',
    pricePerQuantity: 2.0,
    dateAdded: DateTime(2026, 1, 1),
    isCurrentPrice: true,
  );
}

class _FakeRepository implements PersistenceRepository {
  _FakeRepository({
    required this.items,
    required this.supermarkets,
    this.families = const [],
    void Function(ProductItem item)? onSaveItem,
  }) : _onSaveItem = onSaveItem;

  final List<ProductFamily> families;
  final List<ProductItem> items;
  final List<Supermarket> supermarkets;
  final void Function(ProductItem item)? _onSaveItem;

  final List<ProductItem> savedItems = [];
  final List<ProductFamily> savedFamilies = [];

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
    _onSaveItem?.call(item);
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
