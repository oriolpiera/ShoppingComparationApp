import '../../../core/normalization/family_unit_normalization.dart';
import 'entities/product_family.dart';
import 'entities/product_item.dart';
import 'entities/shopping_list_entry.dart';
import 'units/measurement.dart';
import 'units/shopping_units.dart';

const _costEpsilon = 1e-9;

class ShoppingOptimizationPendingEntry {
  const ShoppingOptimizationPendingEntry({
    required this.shoppingListEntryId,
    required this.productFamilyId,
    required this.productFamilyName,
    required this.quantity,
    required this.isInactiveFamily,
  });

  final int shoppingListEntryId;
  final int productFamilyId;
  final String productFamilyName;
  final int quantity;
  final bool isInactiveFamily;
}

class ShoppingOptimizationResolvedEntry {
  const ShoppingOptimizationResolvedEntry({
    required this.shoppingListEntryId,
    required this.productFamilyId,
    required this.productFamilyName,
    required this.quantity,
    required this.bestItem,
    required this.estimatedCost,
  });

  final int shoppingListEntryId;
  final int productFamilyId;
  final String productFamilyName;
  final int quantity;
  final ProductItem bestItem;
  final double estimatedCost;
}

class ShoppingOptimizationGroup {
  const ShoppingOptimizationGroup({
    required this.supermarketId,
    required this.supermarketName,
    required this.entries,
  });

  final int supermarketId;
  final String supermarketName;
  final List<ShoppingOptimizationResolvedEntry> entries;
}

class ShoppingOptimizationResult {
  const ShoppingOptimizationResult({
    required this.groups,
    required this.pendingEntries,
  });

  final List<ShoppingOptimizationGroup> groups;
  final List<ShoppingOptimizationPendingEntry> pendingEntries;
}

ShoppingOptimizationResult optimizeShoppingList({
  required List<ShoppingListEntry> shoppingList,
  required Map<int, ProductFamily> familyById,
  required Map<int, String> supermarketNameById,
  required Iterable<ProductItem> items,
}) {
  final activeFamilyIds = {
    for (final family in familyById.values)
      if (family.id != null && family.isActive) family.id!,
  };

  final itemsByFamily = <int, List<ProductItem>>{};
  for (final item in items.where(
    (i) =>
        i.isActive &&
        i.isCurrentPrice &&
        activeFamilyIds.contains(i.productFamilyId),
  )) {
    itemsByFamily.putIfAbsent(item.productFamilyId, () => []).add(item);
  }

  final groupedEntries = <int, List<ShoppingOptimizationResolvedEntry>>{};
  final pendingEntries = <ShoppingOptimizationPendingEntry>[];

  for (final entry in shoppingList) {
    final family = familyById[entry.productFamilyId];
    if (family == null) continue;

    final isInactiveFamily = !family.isActive;
    if (isInactiveFamily) {
      pendingEntries.add(
        ShoppingOptimizationPendingEntry(
          shoppingListEntryId: entry.id ?? -1,
          productFamilyId: entry.productFamilyId,
          productFamilyName: family.name,
          quantity: entry.quantity,
          isInactiveFamily: isInactiveFamily,
        ),
      );
      continue;
    }

    final bestCandidate = _selectBestCandidate(
      entry: entry,
      family: family,
      items: itemsByFamily[entry.productFamilyId] ?? const [],
    );
    if (bestCandidate == null) {
      pendingEntries.add(
        ShoppingOptimizationPendingEntry(
          shoppingListEntryId: entry.id ?? -1,
          productFamilyId: entry.productFamilyId,
          productFamilyName: family.name,
          quantity: entry.quantity,
          isInactiveFamily: false,
        ),
      );
      continue;
    }

    final bestItem = bestCandidate.item;

    final marketName = supermarketNameById[bestItem.supermarketId];
    if (marketName == null) {
      pendingEntries.add(
        ShoppingOptimizationPendingEntry(
          shoppingListEntryId: entry.id ?? -1,
          productFamilyId: entry.productFamilyId,
          productFamilyName: family.name,
          quantity: entry.quantity,
          isInactiveFamily: false,
        ),
      );
      continue;
    }

    groupedEntries.putIfAbsent(bestItem.supermarketId, () => []).add(
          ShoppingOptimizationResolvedEntry(
            shoppingListEntryId: entry.id ?? -1,
            productFamilyId: entry.productFamilyId,
            productFamilyName: family.name,
            quantity: entry.quantity,
            bestItem: bestItem,
            estimatedCost: bestCandidate.estimatedCost,
          ),
        );
  }

  final groups = groupedEntries.entries
      .map(
        (entry) => ShoppingOptimizationGroup(
          supermarketId: entry.key,
          supermarketName: supermarketNameById[entry.key]!,
          entries: entry.value,
        ),
      )
      .toList()
    ..sort((a, b) => a.supermarketName.compareTo(b.supermarketName));

  return ShoppingOptimizationResult(
    groups: groups,
    pendingEntries: pendingEntries,
  );
}

bool isBetterOptimizedItem(ProductItem candidate, ProductItem current) {
  final byUnit = candidate.pricePerQuantity.compareTo(current.pricePerQuantity);
  if (byUnit != 0) return byUnit < 0;

  final byPrice = candidate.price.compareTo(current.price);
  if (byPrice != 0) return byPrice < 0;

  final byDate = candidate.dateAdded.compareTo(current.dateAdded);
  if (byDate != 0) return byDate > 0;

  final candidateId = candidate.id ?? 1 << 30;
  final currentId = current.id ?? 1 << 30;
  return candidateId < currentId;
}

_OptimizedCandidate? _selectBestCandidate({
  required ShoppingListEntry entry,
  required ProductFamily family,
  required List<ProductItem> items,
}) {
  if (items.isEmpty) return null;

  final needUnit = _parseShoppingUnit(
    family.shoppingUnit ??
        inferShoppingUnitFromUnitType(_effectiveUnitType(items.first)),
  );
  final need = FamilyNeedQuantity(
    amount: entry.quantity.toDouble(),
    unit: needUnit,
  );

  _OptimizedCandidate? winner;
  for (final item in items) {
    final candidate = _buildCandidate(
      entry: entry,
      family: family,
      item: item,
      need: need,
    );
    if (candidate == null) continue;

    if (winner == null || _isBetterCandidate(candidate, winner)) {
      winner = candidate;
    }
  }

  return winner;
}

bool _isBetterCandidate(
  _OptimizedCandidate candidate,
  _OptimizedCandidate current,
) {
  final byCost = candidate.estimatedCost - current.estimatedCost;
  if (byCost.abs() > _costEpsilon) return byCost < 0;
  return isBetterOptimizedItem(candidate.item, current.item);
}

_OptimizedCandidate? _buildCandidate({
  required ShoppingListEntry entry,
  required ProductFamily family,
  required ProductItem item,
  required FamilyNeedQuantity need,
}) {
  final packageQuantityAmount = item.packageQuantityAmount ?? item.quantity;
  final packageQuantityUnit = _effectiveUnitType(item);
  final purchaseMode = normalizePurchaseModeForStorage(
    family.purchaseMode ?? inferPurchaseModeFromUnitType(packageQuantityUnit),
  );

  if (validateItemSemantics(
        shoppingUnit: family.shoppingUnit ?? need.unit.name,
        purchaseMode: purchaseMode,
        packageQuantityAmount: packageQuantityAmount,
        packageQuantityUnit: packageQuantityUnit,
      ) !=
      null) {
    return null;
  }

  try {
    final offer = FamilyOffer(
      id: '${entry.productFamilyId}:${item.id ?? item.name}:${item.supermarketId}',
      price: item.price,
      purchaseMode: _parsePurchaseMode(purchaseMode),
      packageQuantity: PackageQuantity(
        amount: packageQuantityAmount,
        unit: _parseMeasurementUnit(packageQuantityUnit),
      ),
    );

    return _OptimizedCandidate(
      item: item,
      estimatedCost: offer.totalCostFor(need),
    );
  } on ArgumentError catch (_) {
    return null;
  } on UnitCompatibilityException catch (_) {
    return null;
  }
}

String _effectiveUnitType(ProductItem item) {
  return item.packageQuantityUnit ??
      item.normalizedMeasurementUnit ??
      item.unitType;
}

ShoppingUnit _parseShoppingUnit(String value) {
  return switch (normalizeShoppingUnitForStorage(value)) {
    'liter' => ShoppingUnit.liter,
    'piece' => ShoppingUnit.piece,
    _ => ShoppingUnit.kilogram,
  };
}

PurchaseMode _parsePurchaseMode(String value) {
  return switch (normalizePurchaseModeForStorage(value)) {
    'weighted' => PurchaseMode.weighted,
    'piece' => PurchaseMode.piece,
    _ => PurchaseMode.packaged,
  };
}

MeasurementUnit _parseMeasurementUnit(String value) {
  return switch (normalizeUnitTypeForComparison(value)) {
    'g' => MeasurementUnit.gram,
    'ml' => MeasurementUnit.milliliter,
    'l' => MeasurementUnit.liter,
    'unit' => MeasurementUnit.unit,
    _ => MeasurementUnit.kilogram,
  };
}

class _OptimizedCandidate {
  const _OptimizedCandidate({required this.item, required this.estimatedCost});

  final ProductItem item;
  final double estimatedCost;
}
