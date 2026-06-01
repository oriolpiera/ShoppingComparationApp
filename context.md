# Code Context

## Files Retrieved
1. `CONTEXT.md` (lines 1-83) - canonical domain vocabulary and resolved behavior for Product Families, Product Items, barcode registration, and Shopping List entries.
2. `docs/architecture.md` (lines 1-120) - intended layer responsibilities and dependency direction for future integration work.
3. `lib/features/persistence/domain/entities/product_family.dart` (lines 1-11) - current Product Family domain fields.
4. `lib/features/persistence/domain/entities/product_item.dart` (lines 1-31) - current Product Item domain fields relevant to catalog/prices.
5. `lib/features/persistence/domain/entities/shopping_list_entry.dart` (lines 1-10) - Shopping List is family-based, not item/SKU based.
6. `lib/features/persistence/domain/entities/optimized_shopping.dart` (lines 1-37) - optimized list output groups by supermarket and embeds chosen Product Item.
7. `lib/features/persistence/domain/shopping_list_optimizer.dart` (lines 1-126) - core optimization algorithm and pending-entry behavior.
8. `lib/features/persistence/domain/repositories/persistence_repository.dart` (lines 1-43) - repository contract, barcode APIs, quick capture, and optimized list API.
9. `lib/core/database/drift_database.dart` (lines 14-54) - persisted schema for families/items/shopping list, including nullable barcode and legacy `productItemId`.
10. `lib/core/database/dao/persistence_dao.dart` (lines 35-82) - Product Item queries and exact barcode lookup filter.
11. `lib/features/persistence/data/repositories/drift_persistence_repository.dart` (lines 55-461) - mapping, family reuse, barcode registration, rollover, and optimized list construction.
12. `lib/features/products/data/open_food_facts_name_prefill_service.dart` (lines 1-75) - only OpenFoodFacts implementation; product-name-only lookup by barcode.
13. `lib/features/home/presentation/model_records_pages.dart` (lines 937-1835, 1880-2244) - Product Items scan/manual barcode flow and Shopping List UI/optimization flow.
14. `lib/features/home/application/product_family_comparison_module.dart` (lines 1-57) - Product Family comparison sorting/filtering.
15. `lib/core/normalization/family_unit_normalization.dart` (lines 1-66) - family key normalization and constrained unit handling.
16. `test/shopping_list_optimizer_test.dart` (lines 1-181) - tests for optimizer selection and pending rows.
17. `test/open_food_facts_name_prefill_service_test.dart` (lines 1-46) - tests confirm OFF service only parses `product_name` and swallows failures.
18. `test/issue7_barcode_repository_test.dart` (lines 46-162) - tests for barcode exact lookup, no-op registration, and price rollover.
19. `test/features/home/application/product_family_comparison_module_test.dart` (lines 1-88) - tests for family comparison filters/sort.
20. `test/family_unit_normalization_test.dart` (lines 1-35) - tests confirm only `kg`/`L` display assumptions.

## Key Code

Current core entities are minimal and local-first:

```dart
// lib/features/persistence/domain/entities/product_family.dart:1-11
class ProductFamily {
  final int? id;
  final String name;
  final bool isActive;
}

// lib/features/persistence/domain/entities/product_item.dart:1-31
class ProductItem {
  final String name;
  final int productFamilyId;
  final int supermarketId;
  final double price;
  final double quantity;
  final String unitType;
  final double pricePerQuantity;
  final DateTime dateAdded;
  final bool isCurrentPrice;
  final String? barcode;
}
```

Shopping List entries are already Product-Family based:

```dart
// lib/features/persistence/domain/entities/shopping_list_entry.dart:1-10
class ShoppingListEntry {
  final int? id;
  final int productFamilyId;
  final int quantity;
}
```

Optimization picks one best current active Product Item per active family, then groups by its supermarket:

```dart
// lib/features/persistence/domain/shopping_list_optimizer.dart:52-73
for (final item in items.where(
  (i) => i.isActive && i.isCurrentPrice && activeFamilyIds.contains(i.productFamilyId),
)) {
  final current = bestByFamily[item.productFamilyId];
  if (current == null || isBetterOptimizedItem(item, current)) {
    bestByFamily[item.productFamilyId] = item;
  }
}
```

Tie-breaks are unit price, absolute price, newest date, then lowest id (`shopping_list_optimizer.dart:119-126`). Estimated cost is `quantity * bestItem.pricePerQuantity` (`optimized_shopping.dart:17-18`), so Shopping List quantity means “number of normalized units”, not necessarily package count.

Barcode behavior is exact match after trim, current+active only:

```dart
// lib/core/database/dao/persistence_dao.dart:69-80
Future<List<ProductItemTableData>> getCurrentActiveItemsByBarcode(String barcode) {
  final query = db.select(db.productItemTable)
    ..where((t) =>
      t.barcode.equals(barcode) &
      t.isCurrentPrice.equals(true) &
      t.actiu.equals(true));
  return query.get();
}
```

Scanned price registration is local and barcode-required: it trims barcode, compares `price + quantity + unitType` in the same supermarket, no-ops on identical tuple, otherwise rolls over previous current rows in that supermarket and inserts a new current `ProductItem` (`drift_persistence_repository.dart:276-358`).

OpenFoodFacts integration is only a nullable name prefill:

```dart
// lib/features/products/data/open_food_facts_name_prefill_service.dart:13-24
Future<String?> tryGetProductNameByBarcode(String barcode) async {
  final normalizedBarcode = barcode.trim();
  if (normalizedBarcode.isEmpty) return null;
  final uri = Uri.https(
    'world.openfoodfacts.org',
    '/api/v2/product/$normalizedBarcode',
    {'fields': 'product_name'},
  );
  ...
}
```

No OpenPrices code exists (`grep` found no `OpenPrices/openprices/open prices` matches).

## Architecture

The intended architecture is layered (`docs/architecture.md:17-57`): Presentation -> Application -> Domain -> Data. Current code is partly layered but pragmatic:

- Domain entities and optimizer are pure Dart and testable.
- Drift repository maps persistence rows into domain objects and implements family reuse, barcode registration, and optimization assembly.
- `model_records_pages.dart` is a large presentation file that directly orchestrates repository calls, scan flow, barcode match page, registration sheet, and shopping list logic. For a bigger OpenFoodFacts/OpenPrices pivot, extracting application/use-case services would fit the documented architecture better.

Data model readiness:

- Product Family: only `id`, `name`, `isActive`; no normalized key stored, no external taxonomy/category mapping, no OFF category/tag fields.
- Product Item: enough for local price comparison (`price`, `quantity`, `unitType`, `pricePerQuantity`, `supermarketId`, current/history, optional `barcode`), but lacks external catalog/prices fields: external product id/source, OFF code separate from local barcode, brands, generic names, quantity/package text, categories, image URL, nutrition fields, source attribution, currency, price observation timestamp separate from insertion, validity/promo flags, OpenPrices location/store identifiers, proof/receipt ids, and confidence/status.
- Shopping List: already product-family optimized. It does not pin concrete product items in domain; `ShoppingListTable.productItemId` remains in DB but is ignored by `ShoppingListEntry` and repository save/load.
- Units: canonical language says Unit Type allowed values are `kg` and `L`; code display treats any non-`L` as `kg` (`family_unit_normalization.dart:27-35`). This is a major constraint for OFF/OpenPrices packaged products (`g`, `ml`, unit/count, pack size) and fresh products sold by piece.

Fresh products without barcode:

- Local Product Items can have `barcode == null`; quick manual capture supports optional barcode (`saveQuickProductItem`, repository contract lines 20-28).
- The scan registration flow requires a non-empty barcode and cannot register a scanned price without it (`registerScannedPrice`, lines 276-285).
- Product-family shopping lists work for fresh products as long as manually captured current Product Items exist for that family.
- There is no external-catalog path for non-barcoded fresh items; matching is only family-name normalization and local Product Items.

## Contradictions / pivot risks

- If the proposed pivot assumes OpenFoodFacts/OpenPrices can populate full catalog/prices today: contradiction. Current OFF code fetches only `product_name`; OpenPrices is absent.
- If the pivot assumes barcode-centric product identity: partial contradiction. Barcode exists and is used, but the core comparison and Shopping List domain is intentionally Product-Family based. Fresh products without barcodes are supported locally but not through external lookup.
- If the pivot assumes shopping lists need to become family-optimized: already implemented. The open question is semantics and quality: quantity units, package counts, missing item handling, and whether “best by unit price” across stores is enough.
- If the pivot assumes broader unit support: contradiction. Existing canonical language and UI constrain units to `kg` and `L`; code falls back unknown units to `kg`.
- If the pivot assumes source-of-truth external prices: contradiction. Current model is local price observations per supermarket, with current/historical rollover. No source attribution, remote freshness, or sync conflict model exists.

## Suggested first design questions

1. Is OpenFoodFacts only for packaged-product metadata prefill, or should it become a canonical external product catalog linked to local Product Families/Product Items?
2. Should OpenPrices prices be imported as Product Items, or modeled as separate external price observations that can be accepted/converted into local Product Items?
3. What is the matching key between external products and Product Families: barcode, OFF categories, product name normalization, user-confirmed family mapping, or a separate alias table?
4. For fresh/no-barcode products, what external source is expected, and how should matching work: family name, supermarket label text, PLU, category, or manual-only?
5. What should Shopping List `quantity` mean: number of packages, kg/L needed, servings, or arbitrary family units? This affects estimated cost and optimization correctness.
6. Are units still limited to `kg`/`L`, or must the domain support `g`, `ml`, unit/count, pack, piece, and conversions?
7. Should optimization minimize cheapest item per family independently, or optimize a whole trip considering supermarket grouping, travel cost, availability confidence, and stale prices?
8. How should external data freshness, attribution, proof, and user trust be represented in UI and persistence?
9. Should inactive/missing supermarkets and imported external stores share the same `Supermarket` model or require external store mapping?
10. Should current local price rollover rules apply to imported price updates, or should imported observations remain historical and separate until user confirms?

## Start Here

Open `lib/features/persistence/domain/entities/product_item.dart` first. It is the central seam: any OpenFoodFacts/OpenPrices pivot must decide whether to extend `ProductItem`, add external observation/catalog entities, or keep external data mapped into local current-price records.