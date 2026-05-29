import 'package:flutter/material.dart';

import '../../../core/scanner/mobile_scanner_port.dart';
import '../../products/data/open_food_facts_name_prefill_service.dart';
import '../../persistence/domain/entities/barcode_match_result.dart';
import '../../persistence/domain/entities/scanned_price_registration_result.dart';

import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/entities/shopping_list_entry.dart';
import '../../persistence/domain/repositories/persistence_repository.dart';
import '../../supermarkets/data/models/supermarket.dart';

class SupermarketsPage extends StatefulWidget {
  const SupermarketsPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  State<SupermarketsPage> createState() => _SupermarketsPageState();
}

class _SupermarketsPageState extends State<SupermarketsPage> {
  final _queryController = TextEditingController();
  late Future<List<Supermarket>> _future;

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

  Future<List<Supermarket>> _load() {
    return widget.repository.getSupermarkets(onlyActive: true);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supermarkets')),
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
            child: FutureBuilder<List<Supermarket>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final query = _queryController.text.toLowerCase().trim();
                final supermarkets = (snapshot.data ?? const []).where((s) {
                  if (query.isEmpty) return true;
                  return s.name.toLowerCase().contains(query) ||
                      (s.address ?? '').toLowerCase().contains(query);
                }).toList();

                if (supermarkets.isEmpty) {
                  return const Center(child: Text('No supermarkets'));
                }

                return ListView.separated(
                  itemCount: supermarkets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = supermarkets[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(item.address ?? '-'),
                      onTap: () async {
                        final action = await Navigator.of(context)
                            .push<_SupermarketDetailsAction>(
                          MaterialPageRoute(
                            builder: (_) => _SupermarketDetailsPage(item: item),
                          ),
                        );

                        if (!mounted) return;

                        if (action == _SupermarketDetailsAction.edit) {
                          await _openForm(item);
                        } else if (action == _SupermarketDetailsAction.delete) {
                          await widget.repository.saveSupermarket(
                            Supermarket(
                              id: item.id,
                              name: item.name,
                              address: item.address,
                              isActive: false,
                            ),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Supermarket deleted'),
                              ),
                            );
                          }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(Supermarket? supermarket) async {
    final nameController = TextEditingController(text: supermarket?.name ?? '');
    final addressController = TextEditingController(
      text: supermarket?.address ?? '',
    );

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(supermarket == null ? 'Add supermarket' : 'Edit supermarket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
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
    );

    if (save == true && nameController.text.trim().isNotEmpty) {
      await widget.repository.saveSupermarket(
        Supermarket(
          id: supermarket?.id,
          name: nameController.text.trim(),
          address: addressController.text.trim().isEmpty
              ? null
              : addressController.text.trim(),
          isActive: true,
        ),
      );
      _refresh();
    }
  }
}

class ProductFamiliesPage extends StatefulWidget {
  const ProductFamiliesPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  State<ProductFamiliesPage> createState() => _ProductFamiliesPageState();
}

class _ProductFamiliesPageState extends State<ProductFamiliesPage> {
  final _queryController = TextEditingController();
  late Future<List<ProductFamily>> _future;

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

  Future<List<ProductFamily>> _load() {
    return widget.repository.getProductFamilies(onlyActive: true);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product families')),
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
            child: FutureBuilder<List<ProductFamily>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final query = _queryController.text.toLowerCase().trim();
                final families = (snapshot.data ?? const []).where((f) {
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
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      onTap: () async {
                        final action = await Navigator.of(context)
                            .push<_ProductFamilyDetailsAction>(
                          MaterialPageRoute(
                            builder: (_) => _ProductFamilyDetailsPage(
                              item: item,
                              repository: widget.repository,
                            ),
                          ),
                        );

                        if (!mounted) return;

                        if (action == _ProductFamilyDetailsAction.edit) {
                          await _openForm(item);
                        } else if (action ==
                            _ProductFamilyDetailsAction.deleteKeepItems) {
                          await widget.repository.saveProductFamily(
                            ProductFamily(
                              id: item.id,
                              name: item.name,
                              isActive: false,
                            ),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product family deleted'),
                              ),
                            );
                          }
                        } else if (action ==
                            _ProductFamilyDetailsAction
                                .deleteAndInactivateItems) {
                          final allItems =
                              await widget.repository.getProductItems(
                            productFamilyId: item.id,
                            onlyCurrentPrice: false,
                          );
                          for (final productItem
                              in allItems.where((p) => p.isActive)) {
                            await widget.repository.saveProductItem(
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
                          await widget.repository.saveProductFamily(
                            ProductFamily(
                              id: item.id,
                              name: item.name,
                              isActive: false,
                            ),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Product family and active Product Items deleted',
                                ),
                              ),
                            );
                          }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(ProductFamily? family) async {
    final nameController = TextEditingController(text: family?.name ?? '');

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(family == null ? 'Add product family' : 'Edit product family'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
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
    );

    final nextName = nameController.text.trim();
    if (save == true && nextName.isNotEmpty) {
      await widget.repository.saveProductFamily(
        ProductFamily(
          id: family?.id,
          name: nextName,
          isActive: true,
        ),
      );
      _refresh();
    }
  }
}

enum _SupermarketDetailsAction { edit, delete }

class _SupermarketDetailsPage extends StatelessWidget {
  const _SupermarketDetailsPage({required this.item});

  final Supermarket item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supermarket details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pop(context, _SupermarketDetailsAction.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailRow(label: 'Name', value: item.name),
          _DetailRow(
              label: 'Address',
              value: item.address?.trim().isEmpty == true
                  ? '—'
                  : (item.address ?? '—')),
          _DetailRow(label: 'Active', value: item.isActive ? 'Yes' : 'No'),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete supermarket?'),
                  content:
                      const Text('This will mark the supermarket as inactive.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true && context.mounted) {
                Navigator.pop(context, _SupermarketDetailsAction.delete);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

enum _ProductFamilyDetailsAction {
  edit,
  deleteKeepItems,
  deleteAndInactivateItems,
}

class _ProductFamilyDetailsPage extends StatefulWidget {
  const _ProductFamilyDetailsPage({
    required this.item,
    required this.repository,
  });

  final ProductFamily item;
  final PersistenceRepository repository;

  @override
  State<_ProductFamilyDetailsPage> createState() =>
      _ProductFamilyDetailsPageState();
}

class _ProductFamilyDetailsPageState extends State<_ProductFamilyDetailsPage> {
  late Future<_ProductFamilyDetailsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProductFamilyDetailsData> _load() async {
    final familyId = widget.item.id;
    if (familyId == null) {
      return const _ProductFamilyDetailsData([], {}, 0);
    }

    final items = await widget.repository.getProductItems(
      productFamilyId: familyId,
      onlyCurrentPrice: false,
    );
    final supermarkets = await widget.repository.getSupermarkets(
      onlyActive: false,
    );
    final supermarketById = {
      for (final s in supermarkets)
        if (s.id != null) s.id!: s,
    };

    final activeItemCount = items.where((i) => i.isActive).length;
    return _ProductFamilyDetailsData(items, supermarketById, activeItemCount);
  }

  Future<void> _openItemDetails(
    ProductItem item,
    String familyName,
    String supermarketName,
  ) async {
    final action = await Navigator.of(context).push<_ProductItemDetailsAction>(
      MaterialPageRoute(
        builder: (_) => _ProductItemDetailsPage(
          item: item,
          familyName: familyName,
          supermarketName: supermarketName,
          formattedDateAdded: _formatDateAdded(context, item.dateAdded),
        ),
      ),
    );

    if (!mounted || action != _ProductItemDetailsAction.edit) return;

    await _editProductItem(item);
    setState(() => _future = _load());
  }

  Future<void> _editProductItem(ProductItem item) async {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    var unitType = item.unitType.trim().toLowerCase() == 'l' ? 'L' : 'kg';

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Product Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: unitType,
                  decoration: const InputDecoration(labelText: 'Unit type'),
                  items: const [
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                    DropdownMenuItem(value: 'L', child: Text('L')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => unitType = value);
                    }
                  },
                ),
              ],
            ),
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

    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final quantity = double.tryParse(quantityController.text.trim());

    if (save == true &&
        name.isNotEmpty &&
        price != null &&
        price > 0 &&
        quantity != null &&
        quantity > 0) {
      await widget.repository.saveProductItem(
        ProductItem(
          id: item.id,
          name: name,
          isActive: item.isActive,
          productFamilyId: item.productFamilyId,
          supermarketId: item.supermarketId,
          price: price,
          quantity: quantity,
          unitType: unitType,
          pricePerQuantity: price / quantity,
          dateAdded: item.dateAdded,
          isCurrentPrice: item.isCurrentPrice,
          barcode: item.barcode,
        ),
      );
    }
  }

  Future<void> _addFamilyToShoppingList() async {
    final familyId = widget.item.id;
    if (familyId == null) return;

    final quantityController = TextEditingController(text: '1');
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to shopping list'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    final quantity = int.tryParse(quantityController.text.trim());
    if (shouldSave == true && quantity != null && quantity > 0) {
      try {
        await widget.repository.addOrIncrementShoppingListEntry(
          productFamilyId: familyId,
          quantity: quantity,
        );
        final entries = await widget.repository.getShoppingList();
        final exists = entries.any((e) => e.productFamilyId == familyId);
        if (!mounted) return;
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to shopping list')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not add to shopping list')),
          );
        }
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add to shopping list')),
        );
      }
    }
  }

  String _formatDateAdded(BuildContext context, DateTime dateTime) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(dateTime);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(dateTime),
      alwaysUse24HourFormat: true,
    );
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product family details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pop(context, _ProductFamilyDetailsAction.edit),
          ),
        ],
      ),
      body: FutureBuilder<_ProductFamilyDetailsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data =
              snapshot.data ?? const _ProductFamilyDetailsData([], {}, 0);
          final comparisonItems = data.items
              .where((i) => i.isCurrentPrice && i.isActive)
              .toList()
            ..sort((a, b) {
              final byUnit = a.pricePerQuantity.compareTo(b.pricePerQuantity);
              if (byUnit != 0) return byUnit;
              final byPrice = a.price.compareTo(b.price);
              if (byPrice != 0) return byPrice;
              final marketA = data.supermarketById[a.supermarketId]?.name ?? '';
              final marketB = data.supermarketById[b.supermarketId]?.name ?? '';
              return marketA.toLowerCase().compareTo(marketB.toLowerCase());
            });

          final bestUnitPrice = comparisonItems.isEmpty
              ? null
              : comparisonItems.first.pricePerQuantity;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailRow(label: 'Name', value: widget.item.name),
              _DetailRow(
                label: 'Active',
                value: widget.item.isActive ? 'Yes' : 'No',
              ),
              _DetailRow(
                label: 'Current active items count',
                value: '${comparisonItems.length}',
              ),
              _DetailRow(
                label: 'Best unit price',
                value: bestUnitPrice == null
                    ? '—'
                    : bestUnitPrice.toStringAsFixed(2),
              ),
              const SizedBox(height: 16),
              const Text(
                'Product Items comparison',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (comparisonItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No current active Product Items'),
                )
              else
                ...comparisonItems.map((productItem) {
                  final supermarket =
                      data.supermarketById[productItem.supermarketId];
                  final supermarketName =
                      supermarket?.name ?? 'Unknown supermarket';
                  final inactiveSupermarket =
                      supermarket == null || !supermarket.isActive;
                  final unitType =
                      productItem.unitType.trim().toLowerCase() == 'l'
                          ? 'L'
                          : 'kg';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$supermarketName · ${productItem.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (inactiveSupermarket)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            child: const Text(
                              'inactive supermarket',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '€${productItem.price.toStringAsFixed(2)} · ${productItem.quantity} $unitType · ${productItem.pricePerQuantity.toStringAsFixed(2)} €/$unitType',
                    ),
                    onTap: () => _openItemDetails(
                      productItem,
                      widget.item.name,
                      supermarketName,
                    ),
                  );
                }),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _addFamilyToShoppingList,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Add to shopping list'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final activeCount = data.activeItemCount;
                  if (activeCount > 0) {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete product family?'),
                        content: Text(
                          'This family has $activeCount active Product Items. Inactivating it may hide it from active family lists.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete != true || !context.mounted) return;

                    final action =
                        await showDialog<_ProductFamilyDetailsAction>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Choose Product Items action'),
                        content: const Text(
                          'Choose what to do with active Product Items.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton.tonal(
                            onPressed: () => Navigator.pop(
                              context,
                              _ProductFamilyDetailsAction.deleteKeepItems,
                            ),
                            child: const Text('Keep active items'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(
                              context,
                              _ProductFamilyDetailsAction
                                  .deleteAndInactivateItems,
                            ),
                            child: const Text('Inactivate all active items'),
                          ),
                        ],
                      ),
                    );

                    if (action == null || !context.mounted) return;
                    Navigator.pop(context, action);
                    return;
                  }

                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete product family?'),
                      content: const Text(
                        'This will mark the product family as inactive.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true && context.mounted) {
                    Navigator.pop(
                      context,
                      _ProductFamilyDetailsAction.deleteKeepItems,
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductFamilyDetailsData {
  const _ProductFamilyDetailsData(
    this.items,
    this.supermarketById,
    this.activeItemCount,
  );

  final List<ProductItem> items;
  final Map<int, Supermarket> supermarketById;
  final int activeItemCount;
}

class ProductItemsPage extends StatefulWidget {
  ProductItemsPage({
    super.key,
    required this.repository,
    OpenFoodFactsNamePrefillService? namePrefillService,
  }) : namePrefillService =
            namePrefillService ?? OpenFoodFactsNamePrefillService();

  final PersistenceRepository repository;
  final OpenFoodFactsNamePrefillService namePrefillService;

  @override
  State<ProductItemsPage> createState() => _ProductItemsPageState();
}

class _ProductItemsPageState extends State<ProductItemsPage> {
  final _queryController = TextEditingController();
  late Future<_ProductContext> _future;

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

  Future<_ProductContext> _load() async {
    final items =
        await widget.repository.getProductItems(onlyCurrentPrice: true);
    final families =
        await widget.repository.getProductFamilies(onlyActive: true);
    final supermarkets =
        await widget.repository.getSupermarkets(onlyActive: true);
    final lastUsedSupermarketId =
        await widget.repository.getLastUsedSupermarketId();
    return _ProductContext(
      items,
      families,
      supermarkets,
      lastUsedSupermarketId,
    );
  }

  String _normalizeText(String value) {
    const map = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    final lower = value.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(map[char] ?? char);
    }

    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _openScanFlow() async {
    final scanned = await MobileScannerPort(context).scanBarcode();
    final barcode = (scanned ?? '').trim();

    if (!mounted) return;

    if (barcode.isEmpty) {
      final manual = await _askManualBarcode();
      if (!mounted || manual == null || manual.trim().isEmpty) return;
      await _openBarcodeMatches(manual.trim());
      return;
    }

    await _openBarcodeMatches(barcode);
  }

  Future<String?> _askManualBarcode() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter barcode'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Barcode'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBarcodeMatches(String barcode) async {
    final action = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _BarcodeMatchesPage(
          repository: widget.repository,
          barcode: barcode,
          namePrefillService: widget.namePrefillService,
        ),
      ),
    );
    if (action == true) {
      _refresh();
    }
  }

  String _normalizedUnitType(String unitType) {
    final value = unitType.trim().toLowerCase();
    if (value == 'l') return 'L';
    return 'kg';
  }

  RichText _buildMetricsText(BuildContext context, ProductItem item) {
    final unitType = _normalizedUnitType(item.unitType);
    final colorScheme = Theme.of(context).colorScheme;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '€${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' · ${item.quantity} $unitType',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: ' · ${item.pricePerQuantity.toStringAsFixed(2)} €/$unitType',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateAdded(BuildContext context, DateTime dateTime) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(dateTime);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(dateTime),
      alwaysUse24HourFormat: true,
    );
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: _openScanFlow,
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner_outlined),
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
            child: FutureBuilder<_ProductContext>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data;
                if (data == null) {
                  return const Center(child: Text('No data'));
                }

                final familyNameById = {
                  for (final family in data.families)
                    if (family.id != null) family.id!: family.name,
                };
                final supermarketNameById = {
                  for (final supermarket in data.supermarkets)
                    if (supermarket.id != null)
                      supermarket.id!: supermarket.name,
                };

                final query = _queryController.text.toLowerCase().trim();
                final filtered = data.items
                    .where((i) => i.isActive)
                    .map((i) => (
                          item: i,
                          familyName: familyNameById[i.productFamilyId] ??
                              'Unknown family',
                        ))
                    .where((entry) =>
                        query.isEmpty ||
                        entry.item.name.toLowerCase().contains(query) ||
                        entry.familyName.toLowerCase().contains(query))
                    .toList()
                  ..sort((a, b) {
                    final byFamily = a.familyName.toLowerCase().compareTo(
                          b.familyName.toLowerCase(),
                        );
                    if (byFamily != 0) return byFamily;
                    return a.item.name.toLowerCase().compareTo(
                          b.item.name.toLowerCase(),
                        );
                  });

                if (filtered.isEmpty) {
                  return const Center(child: Text('No products'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final item = entry.item;
                    final supermarketName =
                        supermarketNameById[item.supermarketId] ??
                            'Unknown supermarket';

                    return ListTile(
                      dense: true,
                      title: Text(entry.familyName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${item.name} · $supermarketName'),
                          _buildMetricsText(context, item),
                        ],
                      ),
                      onTap: () async {
                        final action = await Navigator.of(context)
                            .push<_ProductItemDetailsAction>(
                          MaterialPageRoute(
                            builder: (_) => _ProductItemDetailsPage(
                              item: item,
                              familyName: entry.familyName,
                              supermarketName: supermarketName,
                              formattedDateAdded:
                                  _formatDateAdded(context, item.dateAdded),
                            ),
                          ),
                        );

                        if (!mounted) return;

                        if (action == _ProductItemDetailsAction.edit) {
                          await _openForm(item, data);
                        } else if (action == _ProductItemDetailsAction.delete) {
                          await widget.repository.saveProductItem(
                            ProductItem(
                              id: item.id,
                              name: item.name,
                              isActive: false,
                              productFamilyId: item.productFamilyId,
                              supermarketId: item.supermarketId,
                              price: item.price,
                              quantity: item.quantity,
                              unitType: item.unitType,
                              pricePerQuantity: item.pricePerQuantity,
                              dateAdded: item.dateAdded,
                              isCurrentPrice: item.isCurrentPrice,
                              barcode: item.barcode,
                            ),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product deleted')),
                            );
                          }
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton.small(
              heroTag: 'manualBarcode',
              onPressed: () async {
                final manual = await _askManualBarcode();
                if (!mounted || manual == null || manual.trim().isEmpty) {
                  return;
                }
                await _openBarcodeMatches(manual.trim());
              },
              child: const Icon(Icons.tag),
            ),
          ),
          FloatingActionButton(
            heroTag: 'addProductItem',
            onPressed: () async {
              final data = await _future;
              if (!mounted) return;
              await _openForm(null, data);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(ProductItem? item, _ProductContext data) async {
    if (data.supermarkets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Need at least one supermarket first'),
          ),
        );
      }
      return;
    }

    final familyById = {
      for (final family in data.families)
        if (family.id != null) family.id!: family,
    };

    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(
      text: item == null ? '' : item.price.toString(),
    );
    final quantityController = TextEditingController(
      text: item == null ? '' : item.quantity.toString(),
    );
    var unitType = _normalizedUnitType(item?.unitType ?? 'kg');
    final familyController = TextEditingController(
      text: item == null ? '' : (familyById[item.productFamilyId]?.name ?? ''),
    );

    final activeMarketIds =
        data.supermarkets.where((s) => s.id != null).map((s) => s.id!).toSet();
    final fallbackMarketId = data.supermarkets.first.id!;
    var supermarketId = item?.supermarketId ??
        ((data.lastUsedSupermarketId != null &&
                activeMarketIds.contains(data.lastUsedSupermarketId))
            ? data.lastUsedSupermarketId!
            : fallbackMarketId);

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add product' : 'Edit product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    final query = textEditingValue.text.trim();
                    if (query.length < 3) {
                      return const Iterable<String>.empty();
                    }
                    final normalizedQuery = _normalizeText(query);
                    final names = data.families
                        .map((f) => f.name)
                        .toSet()
                        .toList()
                      ..sort();
                    return names
                        .where((name) =>
                            _normalizeText(name).contains(normalizedQuery))
                        .take(8);
                  },
                  onSelected: (selection) {
                    familyController.text = selection;
                  },
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                    if (textController.text != familyController.text) {
                      textController.value = TextEditingValue(
                        text: familyController.text,
                        selection: TextSelection.collapsed(
                          offset: familyController.text.length,
                        ),
                      );
                    }
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      onChanged: (value) => familyController.text = value,
                      decoration: const InputDecoration(
                        labelText: 'Family',
                        helperText: 'Suggestions from 3 chars',
                      ),
                    );
                  },
                ),
                DropdownButtonFormField<int>(
                  initialValue: supermarketId,
                  decoration: const InputDecoration(labelText: 'Supermarket'),
                  items: data.supermarkets
                      .map((s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => supermarketId = value);
                    }
                  },
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: unitType,
                  decoration: const InputDecoration(labelText: 'Unit type'),
                  items: const [
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                    DropdownMenuItem(value: 'L', child: Text('L')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => unitType = value);
                    }
                  },
                ),
              ],
            ),
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

    final name = nameController.text.trim();
    final familyName = familyController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final quantity = double.tryParse(quantityController.text.trim());
    if (save == true &&
        name.isNotEmpty &&
        familyName.isNotEmpty &&
        price != null &&
        price > 0 &&
        quantity != null &&
        quantity > 0) {
      if (item == null) {
        await widget.repository.saveQuickProductItem(
          productName: name,
          familyName: familyName,
          supermarketId: supermarketId,
          price: price,
          quantity: quantity,
          unitType: unitType,
        );
      } else {
        final resolvedFamilyId =
            await widget.repository.resolveProductFamilyIdByName(familyName);
        await widget.repository.saveProductItem(
          ProductItem(
            id: item.id,
            name: name,
            isActive: true,
            productFamilyId: resolvedFamilyId,
            supermarketId: supermarketId,
            price: price,
            quantity: quantity,
            unitType: unitType,
            pricePerQuantity: quantity == 0 ? 0 : price / quantity,
            dateAdded: item.dateAdded,
            isCurrentPrice: true,
            barcode: item.barcode,
          ),
        );
      }
      _refresh();
    }
  }
}

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _BarcodeMatchesPage extends StatefulWidget {
  const _BarcodeMatchesPage({
    required this.repository,
    required this.barcode,
    required this.namePrefillService,
  });

  final PersistenceRepository repository;
  final String barcode;
  final OpenFoodFactsNamePrefillService namePrefillService;

  @override
  State<_BarcodeMatchesPage> createState() => _BarcodeMatchesPageState();
}

class _BarcodeMatchesPageState extends State<_BarcodeMatchesPage> {
  late Future<_BarcodeLookupData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BarcodeLookupData> _load() async {
    final matches =
        await widget.repository.findCurrentActiveByBarcode(widget.barcode);

    if (matches.isNotEmpty) {
      return _BarcodeLookupData(matches: matches, prefilledName: null);
    }

    final prefilledName =
        await widget.namePrefillService.tryGetProductNameByBarcode(
      widget.barcode,
    );
    return _BarcodeLookupData(matches: matches, prefilledName: prefilledName);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _createProductItem(_BarcodeLookupData lookupData) async {
    final matches = lookupData.matches;
    final latest = matches.isEmpty ? null : matches.first;
    final data = await _loadCreateData();
    if (!mounted) return;

    if (data.supermarkets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least one active supermarket first.'),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<ScannedPriceRegistrationResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RegisterScannedPriceSheet(
        repository: widget.repository,
        barcode: widget.barcode,
        supermarkets: data.supermarkets,
        lastUsedSupermarketId: data.lastUsedSupermarketId,
        prefilledName: latest?.productItem.name ?? lookupData.prefilledName,
        prefilledFamily: latest?.familyName,
      ),
    );

    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Done')),
    );
    if (result.created) {
      Navigator.of(context).pop(true);
    } else {
      await _refresh();
    }
  }

  Future<_ProductContext> _loadCreateData() async {
    final items =
        await widget.repository.getProductItems(onlyCurrentPrice: true);
    final families =
        await widget.repository.getProductFamilies(onlyActive: true);
    final supermarkets =
        await widget.repository.getSupermarkets(onlyActive: true);
    final lastUsedSupermarketId =
        await widget.repository.getLastUsedSupermarketId();
    return _ProductContext(
        items, families, supermarkets, lastUsedSupermarketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode matches: ${widget.barcode}')),
      body: FutureBuilder<_BarcodeLookupData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final lookupData =
              snapshot.data ?? const _BarcodeLookupData(matches: []);
          final matches = lookupData.matches;
          if (matches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'No current active Product Items for this barcode.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _createProductItem(lookupData),
                      child: const Text('Create Product Item'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Re-scan'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final item = match.productItem;
                    return ListTile(
                      title: Text('${match.supermarketName} · ${item.name}'),
                      subtitle: Text(
                        '€${item.price.toStringAsFixed(2)} · ${item.quantity} ${item.unitType} · ${item.pricePerQuantity.toStringAsFixed(2)} €/${item.unitType}',
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Re-scan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _createProductItem(lookupData),
                          child: const Text('Create Product Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarcodeLookupData {
  const _BarcodeLookupData({
    required this.matches,
    this.prefilledName,
  });

  final List<BarcodeMatchResult> matches;
  final String? prefilledName;
}

class _RegisterScannedPriceSheet extends StatefulWidget {
  const _RegisterScannedPriceSheet({
    required this.repository,
    required this.barcode,
    required this.supermarkets,
    required this.lastUsedSupermarketId,
    this.prefilledName,
    this.prefilledFamily,
  });

  final PersistenceRepository repository;
  final String barcode;
  final List<Supermarket> supermarkets;
  final int? lastUsedSupermarketId;
  final String? prefilledName;
  final String? prefilledFamily;

  @override
  State<_RegisterScannedPriceSheet> createState() =>
      _RegisterScannedPriceSheetState();
}

class _RegisterScannedPriceSheetState
    extends State<_RegisterScannedPriceSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _familyController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  String _unitType = 'kg';
  late int _supermarketId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefilledName ?? '');
    _familyController =
        TextEditingController(text: widget.prefilledFamily ?? '');
    _priceController = TextEditingController();
    _quantityController = TextEditingController(text: '1');

    if (widget.supermarkets.isEmpty) {
      _supermarketId = 0;
      return;
    }

    final fallbackId = widget.supermarkets.first.id ?? 0;
    final allowedIds = widget.supermarkets
        .where((s) => s.id != null)
        .map((s) => s.id!)
        .toSet();
    _supermarketId = (widget.lastUsedSupermarketId != null &&
            allowedIds.contains(widget.lastUsedSupermarketId))
        ? widget.lastUsedSupermarketId!
        : fallbackId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final family = _familyController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());

    if (name.isEmpty || family.isEmpty || price == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
        ),
      );
      return;
    }

    final result = await widget.repository.registerScannedPrice(
      barcode: widget.barcode,
      productName: name,
      familyName: family,
      supermarketId: _supermarketId,
      price: price,
      quantity: quantity,
      unitType: _unitType,
    );
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                readOnly: true,
                initialValue: widget.barcode,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _familyController,
                decoration: const InputDecoration(labelText: 'Family'),
              ),
              DropdownButtonFormField<int>(
                initialValue: _supermarketId,
                decoration: const InputDecoration(labelText: 'Supermarket'),
                items: widget.supermarkets
                    .where((s) => s.id != null)
                    .map(
                      (s) => DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _supermarketId = value);
                  }
                },
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _unitType,
                decoration: const InputDecoration(labelText: 'Unit type'),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'L', child: Text('L')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _unitType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late Future<_ShoppingListViewData> _future;
  final Set<int> _selectedEntryIds = {};
  final Set<int> _boughtEntries = {};

  bool get _selectionMode => _selectedEntryIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ShoppingListViewData> _load() async {
    final entries = await widget.repository.getShoppingList();
    final families =
        await widget.repository.getProductFamilies(onlyActive: false);
    final activeFamilies = await widget.repository.getProductFamilies();
    final items =
        await widget.repository.getProductItems(onlyCurrentPrice: true);
    final supermarkets =
        await widget.repository.getSupermarkets(onlyActive: true);

    final familyById = {
      for (final family in families)
        if (family.id != null) family.id!: family,
    };
    final marketNameById = {
      for (final market in supermarkets)
        if (market.id != null) market.id!: market.name,
    };

    final bestByFamily = <int, ProductItem>{};
    for (final item in items.where((i) => i.isActive && i.isCurrentPrice)) {
      final current = bestByFamily[item.productFamilyId];
      if (current == null || _isBetterItem(item, current)) {
        bestByFamily[item.productFamilyId] = item;
      }
    }

    final optimizedGroups = <String, List<_ShoppingRow>>{};
    final pendingRows = <_ShoppingRow>[];

    for (final entry in entries) {
      final family = familyById[entry.productFamilyId];
      if (family == null) continue;

      final bestItem = bestByFamily[entry.productFamilyId];
      final isInactiveFamily = !family.isActive;
      if (bestItem == null || isInactiveFamily) {
        pendingRows.add(
          _ShoppingRow(
            entryId: entry.id ?? -1,
            familyId: entry.productFamilyId,
            familyName: family.name,
            quantity: entry.quantity,
            isInactiveFamily: isInactiveFamily,
          ),
        );
        continue;
      }

      final marketName = marketNameById[bestItem.supermarketId];
      if (marketName == null) {
        pendingRows.add(
          _ShoppingRow(
            entryId: entry.id ?? -1,
            familyId: entry.productFamilyId,
            familyName: family.name,
            quantity: entry.quantity,
          ),
        );
        continue;
      }

      optimizedGroups.putIfAbsent(marketName, () => []).add(
            _ShoppingRow(
              entryId: entry.id ?? -1,
              familyId: entry.productFamilyId,
              familyName: family.name,
              quantity: entry.quantity,
              bestItem: bestItem,
            ),
          );
    }

    final sortedGroups = optimizedGroups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final activeFamilyOptions = activeFamilies
        .where((f) => f.id != null)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return _ShoppingListViewData(
      groupedRows: sortedGroups,
      pendingRows: pendingRows,
      activeFamilyOptions: activeFamilyOptions,
    );
  }

  bool _isBetterItem(ProductItem candidate, ProductItem current) {
    final byUnit =
        candidate.pricePerQuantity.compareTo(current.pricePerQuantity);
    if (byUnit != 0) return byUnit < 0;
    final byPrice = candidate.price.compareTo(current.price);
    if (byPrice != 0) return byPrice < 0;
    final byDate = candidate.dateAdded.compareTo(current.dateAdded);
    if (byDate != 0) return byDate > 0;
    final candidateId = candidate.id ?? 1 << 30;
    final currentId = current.id ?? 1 << 30;
    return candidateId < currentId;
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _updateQuantity(_ShoppingRow row, int delta) async {
    final nextUnits = (row.quantity + delta).clamp(0, 9999);
    await widget.repository.saveShoppingListEntry(
      ShoppingListEntry(
        id: row.entryId < 0 ? null : row.entryId,
        productFamilyId: row.familyId,
        quantity: nextUnits,
      ),
    );
    _refresh();
  }

  Future<void> _openAddFamilyDialog(_ShoppingListViewData data) async {
    if (data.activeFamilyOptions.isEmpty) return;

    int selectedFamilyId = data.activeFamilyOptions.first.id!;
    final quantityController = TextEditingController(text: '1');

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add family to shopping list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedFamilyId,
                decoration: const InputDecoration(labelText: 'Product family'),
                items: data.activeFamilyOptions
                    .map((f) =>
                        DropdownMenuItem(value: f.id, child: Text(f.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedFamilyId = value);
                  }
                },
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    final quantity = int.tryParse(quantityController.text.trim());
    if (save == true && quantity != null && quantity > 0) {
      await widget.repository.addOrIncrementShoppingListEntry(
        productFamilyId: selectedFamilyId,
        quantity: quantity,
      );
      _refresh();
    }
  }

  Future<void> _deleteSelected() async {
    final count = _selectedEntryIds.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete items?'),
        content: Text('Delete $count items from shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository
          .deleteShoppingListEntries(_selectedEntryIds.toList());
      setState(() {
        _boughtEntries.removeAll(_selectedEntryIds);
        _selectedEntryIds.clear();
      });
      _refresh();
    }
  }

  void _onLongPressRow(_ShoppingRow row) {
    setState(() {
      _selectedEntryIds.add(row.entryId);
    });
  }

  void _onTapRow(_ShoppingRow row) {
    if (!_selectionMode) return;
    setState(() {
      if (_selectedEntryIds.contains(row.entryId)) {
        _selectedEntryIds.remove(row.entryId);
      } else {
        _selectedEntryIds.add(row.entryId);
      }
    });
  }

  void _toggleBought(_ShoppingRow row) {
    setState(() {
      if (_boughtEntries.contains(row.entryId)) {
        _boughtEntries.remove(row.entryId);
      } else {
        _boughtEntries.add(row.entryId);
      }
    });
  }

  Widget _buildRow(_ShoppingRow row) {
    final isSelected = _selectedEntryIds.contains(row.entryId);
    final isBought = _boughtEntries.contains(row.entryId);
    final textColor = row.isInactiveFamily ? Colors.grey.shade700 : null;
    final tileColor = row.isInactiveFamily ? Colors.grey.shade300 : null;

    return ListTile(
      dense: true,
      selected: isSelected,
      tileColor: tileColor,
      onLongPress: () => _onLongPressRow(row),
      onTap: () => _onTapRow(row),
      leading: _selectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => _onTapRow(row),
            )
          : Checkbox(
              value: isBought,
              onChanged: (_) => _toggleBought(row),
            ),
      title: Text(
        row.familyName,
        style: TextStyle(
          color: textColor,
          decoration: isBought ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        row.bestItem == null
            ? (row.isInactiveFamily
                ? 'Inactive family'
                : 'Pending best product item')
            : '${row.bestItem!.name} · €/u ${row.bestItem!.pricePerQuantity.toStringAsFixed(2)} · est. €${(row.quantity * row.bestItem!.pricePerQuantity).toStringAsFixed(2)}',
        style: TextStyle(color: textColor),
      ),
      trailing: _selectionMode
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      row.quantity <= 0 ? null : () => _updateQuantity(row, -1),
                  icon: const Icon(Icons.remove),
                ),
                Text('${row.quantity}'),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _updateQuantity(row, 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ShoppingListViewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(_selectionMode
                ? '${_selectedEntryIds.length} selected'
                : 'Shopping list'),
            actions: [
              if (_selectionMode)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteSelected,
                ),
            ],
          ),
          floatingActionButton: data == null
              ? null
              : FloatingActionButton(
                  onPressed: () => _openAddFamilyDialog(data),
                  child: const Icon(Icons.add),
                ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (data == null) {
                return const Center(child: Text('No shopping items yet'));
              }

              final grouped = data.groupedRows;
              final pending = data.pendingRows;
              if (grouped.isEmpty && pending.isEmpty) {
                return const Center(child: Text('No shopping items yet'));
              }

              return ListView(
                children: [
                  ...grouped.map((group) {
                    final groupTotal = group.value.fold<double>(
                      0,
                      (sum, row) =>
                          sum +
                          (row.bestItem == null
                              ? 0
                              : row.quantity * row.bestItem!.pricePerQuantity),
                    );
                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(group.key),
                      subtitle: Text(
                        'Estimated total: €${groupTotal.toStringAsFixed(2)}',
                      ),
                      children: group.value.map(_buildRow).toList(),
                    );
                  }),
                  if (pending.isNotEmpty)
                    const ListTile(
                      title: Text('Pending / inactive',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ...pending.map(_buildRow),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ShoppingRow {
  const _ShoppingRow({
    required this.entryId,
    required this.familyId,
    required this.familyName,
    required this.quantity,
    this.bestItem,
    this.isInactiveFamily = false,
  });

  final int entryId;
  final int familyId;
  final String familyName;
  final int quantity;
  final ProductItem? bestItem;
  final bool isInactiveFamily;
}

class _ShoppingListViewData {
  const _ShoppingListViewData({
    required this.groupedRows,
    required this.pendingRows,
    required this.activeFamilyOptions,
  });

  final List<MapEntry<String, List<_ShoppingRow>>> groupedRows;
  final List<_ShoppingRow> pendingRows;
  final List<ProductFamily> activeFamilyOptions;
}

enum _ProductItemDetailsAction { edit, delete }

class _ProductItemDetailsPage extends StatelessWidget {
  const _ProductItemDetailsPage({
    required this.item,
    required this.familyName,
    required this.supermarketName,
    required this.formattedDateAdded,
  });

  final ProductItem item;
  final String familyName;
  final String supermarketName;
  final String formattedDateAdded;

  String _yesNo(bool value) => value ? 'Yes' : 'No';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pop(context, _ProductItemDetailsAction.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailRow(label: 'Name', value: item.name),
          _DetailRow(label: 'Family', value: familyName),
          _DetailRow(label: 'Supermarket', value: supermarketName),
          _DetailRow(
              label: 'Price', value: '€${item.price.toStringAsFixed(2)}'),
          _DetailRow(label: 'Quantity', value: item.quantity.toString()),
          _DetailRow(label: 'Unit type', value: item.unitType),
          _DetailRow(
            label: 'Price per quantity',
            value: item.pricePerQuantity.toStringAsFixed(2),
          ),
          _DetailRow(label: 'Date added', value: formattedDateAdded),
          _DetailRow(label: 'Active', value: _yesNo(item.isActive)),
          _DetailRow(
              label: 'Current price', value: _yesNo(item.isCurrentPrice)),
          _DetailRow(
            label: 'Barcode',
            value: (item.barcode == null || item.barcode!.trim().isEmpty)
                ? '—'
                : item.barcode!,
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete product?'),
                  content:
                      const Text('This will mark the product as inactive.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (shouldDelete == true && context.mounted) {
                Navigator.pop(context, _ProductItemDetailsAction.delete);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ProductContext {
  const _ProductContext(
    this.items,
    this.families,
    this.supermarkets,
    this.lastUsedSupermarketId,
  );

  final List<ProductItem> items;
  final List<ProductFamily> families;
  final List<Supermarket> supermarkets;
  final int? lastUsedSupermarketId;
}
