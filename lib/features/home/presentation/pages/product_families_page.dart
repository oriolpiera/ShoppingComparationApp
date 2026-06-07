import 'package:flutter/material.dart';

import '../../../../core/normalization/unit_normalization.dart';
import '../../../../core/validation/family_semantics.dart';
import '../../../persistence/domain/entities/product_family.dart';
import '../../../persistence/domain/entities/product_item.dart';
import '../../../persistence/domain/entities/shopping_list_entry.dart';
import '../../../persistence/domain/repositories/product_family_repository.dart';
import '../../../persistence/domain/repositories/product_item_repository.dart';
import '../../../persistence/domain/repositories/shopping_list_repository.dart';
import '../../../persistence/domain/repositories/supermarket_repository.dart';
import '../../../products/presentation/product_item_capture_form_support.dart';
import '../product_family_details_action.dart';
import '../product_family_details_module.dart';

class ProductFamiliesPage extends StatefulWidget {
  const ProductFamiliesPage({
    super.key,
    required this.productFamilyRepository,
    required this.productItemRepository,
    required this.supermarketRepository,
    required this.shoppingListRepository,
  });

  final ProductFamilyRepository productFamilyRepository;
  final ProductItemRepository productItemRepository;
  final SupermarketRepository supermarketRepository;
  final ShoppingListRepository shoppingListRepository;

  @override
  State<ProductFamiliesPage> createState() => _ProductFamiliesPageState();
}

class _ProductFamiliesPageState extends State<ProductFamiliesPage> {
  final _queryController = TextEditingController();
  late Future<_ProductFamiliesViewData> _future;
  final Set<int> _selectedFamilyIds = {};

  bool get _selectionMode => _selectedFamilyIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<_ProductFamiliesViewData> _load() async {
    final families = await widget.productFamilyRepository.getProductFamilies(
      onlyActive: true,
    );
    final shoppingListEntries =
        await widget.shoppingListRepository.getShoppingNeedEntries();
    final shoppingListFamilyIds = shoppingListEntries
        .map((e) => e.productFamilyId)
        .whereType<int>()
        .toSet();

    return _ProductFamiliesViewData(
      families: families,
      shoppingListFamilyIds: shoppingListFamilyIds,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedFamilyIds.clear();
    });
  }

  void _toggleSelection(int familyId) {
    setState(() {
      if (_selectedFamilyIds.contains(familyId)) {
        _selectedFamilyIds.remove(familyId);
      } else {
        _selectedFamilyIds.add(familyId);
      }
    });
  }

  Future<void> _addSelectedFamiliesToShoppingList() async {
    if (_selectedFamilyIds.isEmpty) return;

    final freshEntries =
        await widget.shoppingListRepository.getShoppingNeedEntries();
    final currentlyOnShoppingList =
        freshEntries.map((e) => e.productFamilyId).whereType<int>().toSet();
    int addedCount = 0;
    int skippedCount = 0;

    for (final familyId in Set.of(_selectedFamilyIds)) {
      if (!currentlyOnShoppingList.contains(familyId)) {
        await widget.shoppingListRepository.saveShoppingNeedEntry(
          ShoppingListEntry(
            productFamilyId: familyId,
            quantity: 1,
          ),
        );
        addedCount++;
      } else {
        skippedCount++;
      }
    }

    if (!mounted) return;

    String message;
    if (addedCount > 0 && skippedCount == 0) {
      message = '$addedCount families added to shopping list.';
    } else if (addedCount == 0 && skippedCount > 0) {
      message = '$skippedCount families already on shopping list and skipped.';
    } else {
      message =
          '$addedCount families added, $skippedCount families already on list.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    _exitSelectionMode();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selectedFamilyIds.length} selected'
              : 'Product families',
        ),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: _addSelectedFamiliesToShoppingList,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _queryController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<_ProductFamiliesViewData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data!;
                final query = _queryController.text.toLowerCase().trim();
                final families = data.families.where((f) {
                  if (query.isEmpty) return true;
                  return f.name.toLowerCase().contains(query);
                }).toList();

                if (families.isEmpty) {
                  return const Center(child: Text('No product families'));
                }

                return ListView.separated(
                  itemCount: families.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = families[index];
                    final familyId = item.id;
                    final isSelected = familyId != null &&
                        _selectedFamilyIds.contains(familyId);

                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      leading: _selectionMode && familyId != null
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(familyId),
                            )
                          : null,
                      title: Text(item.name),
                      onLongPress: () {
                        if (familyId != null) {
                          _toggleSelection(familyId);
                        }
                      },
                      onTap: () async {
                        if (_selectionMode) {
                          if (familyId != null) _toggleSelection(familyId);
                          return;
                        }

                        final action = await Navigator.of(context)
                            .push<ProductFamilyDetailsAction>(
                          MaterialPageRoute(
                            builder: (_) => ProductFamilyDetailsPage(
                              item: item,
                              productItemRepository:
                                  widget.productItemRepository,
                              supermarketRepository:
                                  widget.supermarketRepository,
                              shoppingListRepository:
                                  widget.shoppingListRepository,
                            ),
                          ),
                        );

                        if (!mounted) return;

                        if (action == ProductFamilyDetailsAction.edit) {
                          await _openForm(item);
                        } else if (action ==
                            ProductFamilyDetailsAction.deleteKeepItems) {
                          await widget.productFamilyRepository
                              .saveProductFamily(
                            ProductFamily(
                              id: item.id,
                              name: item.name,
                              isActive: false,
                              shoppingUnit: item.shoppingUnit,
                              purchaseMode: item.purchaseMode,
                            ),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Product family deleted'),
                            ),
                          );
                        } else if (action ==
                            ProductFamilyDetailsAction
                                .deleteAndInactivateItems) {
                          final allItems = await widget.productItemRepository
                              .getProductItems(
                            productFamilyId: item.id,
                            onlyCurrentPrice: false,
                          );
                          for (final productItem in allItems.where(
                            (p) => p.isActive,
                          )) {
                            await widget.productItemRepository.saveProductItem(
                              ProductItem(
                                id: productItem.id,
                                name: productItem.name,
                                isActive: false,
                                productFamilyId: productItem.productFamilyId,
                                supermarketId: productItem.supermarketId,
                                price: productItem.price,
                                quantity: productItem.quantity,
                                unitType: productItem.unitType,
                                pricePerQuantity: productItem.pricePerQuantity,
                                dateAdded: productItem.dateAdded,
                                isCurrentPrice: productItem.isCurrentPrice,
                                barcode: productItem.barcode,
                              ),
                            );
                          }
                          await widget.productFamilyRepository
                              .saveProductFamily(
                            ProductFamily(
                              id: item.id,
                              name: item.name,
                              isActive: false,
                              shoppingUnit: item.shoppingUnit,
                              purchaseMode: item.purchaseMode,
                            ),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Product family and active Product Items deleted',
                              ),
                            ),
                          );
                        }

                        _refresh();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _openForm(null),
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _openForm(ProductFamily? family) async {
    final nameController = TextEditingController(text: family?.name ?? '');
    var shoppingUnit = normalizeShoppingUnitForStorage(family?.shoppingUnit);
    var purchaseMode = normalizePurchaseModeForStorage(family?.purchaseMode);

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            family == null ? 'Add product family' : 'Edit product family',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              DropdownButtonFormField<String>(
                initialValue: shoppingUnit,
                decoration: const InputDecoration(labelText: 'Shopping unit'),
                items: const [
                  DropdownMenuItem(
                    value: 'kilogram',
                    child: Text('kg'),
                  ),
                  DropdownMenuItem(value: 'liter', child: Text('L')),
                  DropdownMenuItem(value: 'piece', child: Text('piece')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => shoppingUnit = value);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: purchaseMode,
                decoration: const InputDecoration(labelText: 'Purchase mode'),
                items: const [
                  DropdownMenuItem(
                    value: 'weighted',
                    child: Text('weighted'),
                  ),
                  DropdownMenuItem(
                    value: 'packaged',
                    child: Text('packaged'),
                  ),
                  DropdownMenuItem(value: 'piece', child: Text('piece')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => purchaseMode = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    final nextName = nameController.text.trim();
    if (save == true && nextName.isNotEmpty) {
      final familyError = validateFamilySemantics(
        shoppingUnit: shoppingUnit,
        purchaseMode: purchaseMode,
      );
      if (familyError != null) {
        if (mounted) {
          showValidationSnackBar(context, familyError);
        }
        return;
      }

      await widget.productFamilyRepository.saveProductFamily(
        ProductFamily(
          id: family?.id,
          name: nextName,
          isActive: true,
          shoppingUnit: shoppingUnit,
          purchaseMode: purchaseMode,
        ),
      );
      _refresh();
    }
  }
}

class _ProductFamiliesViewData {
  const _ProductFamiliesViewData({
    required this.families,
    required this.shoppingListFamilyIds,
  });

  final List<ProductFamily> families;
  final Set<int> shoppingListFamilyIds;
}
