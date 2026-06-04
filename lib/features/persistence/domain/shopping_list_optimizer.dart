import 'entities/product_family.dart';
import 'entities/product_item.dart';
import 'entities/shopping_list_entry.dart';

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
  });

  final int shoppingListEntryId;
  final int productFamilyId;
  final String productFamilyName;
  final int quantity;
  final ProductItem bestItem;
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

  final latestByFamilyAndSupermarket = <(int, int), ProductItem>{};
  for (final item in items.where(
    (i) =>
        i.isActive &&
        i.isCurrentPrice &&
        activeFamilyIds.contains(i.productFamilyId),
  )) {
    final key = (item.productFamilyId, item.supermarketId);
    final current = latestByFamilyAndSupermarket[key];
    if (current == null || isMoreRecentShoppingCandidate(item, current)) {
      latestByFamilyAndSupermarket[key] = item;
    }
  }

  final bestByFamily = <int, ProductItem>{};
  for (final item in latestByFamilyAndSupermarket.values) {
    final current = bestByFamily[item.productFamilyId];
    if (current == null || isBetterOptimizedItem(item, current)) {
      bestByFamily[item.productFamilyId] = item;
    }
  }

  final groupedEntries = <int, List<ShoppingOptimizationResolvedEntry>>{};
  final pendingEntries = <ShoppingOptimizationPendingEntry>[];

  for (final entry in shoppingList) {
    final family = familyById[entry.productFamilyId];
    if (family == null) continue;

    final bestItem = bestByFamily[entry.productFamilyId];
    final isInactiveFamily = !family.isActive;
    if (bestItem == null || isInactiveFamily) {
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

bool isMoreRecentShoppingCandidate(ProductItem candidate, ProductItem current) {
  final byDate = candidate.dateAdded.compareTo(current.dateAdded);
  if (byDate != 0) return byDate > 0;

  final candidateId = candidate.id ?? -1;
  final currentId = current.id ?? -1;
  return candidateId > currentId;
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
