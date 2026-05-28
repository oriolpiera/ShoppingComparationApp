import 'package:flutter/material.dart';

import '../../persistence/domain/entities/optimized_shopping.dart';
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
  const ProductItemsPage({super.key, required this.repository});

  final PersistenceRepository repository;

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
      appBar: AppBar(title: const Text('Products')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = await _future;
          if (!mounted) return;
          await _openForm(null, data);
        },
        child: const Icon(Icons.add),
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

class _ShoppingListPageState extends State<ShoppingListPage> {
  late Future<List<OptimizedShoppingGroup>> _future;
  final Set<int> _boughtEntries = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OptimizedShoppingGroup>> _load() {
    return widget.repository.getOptimizedShoppingList();
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _updateQuantity(OptimizedShoppingItem item, int delta) async {
    final currentUnits = item.quantity.round();
    final nextUnits = (currentUnits + delta).clamp(0, 9999);
    await widget.repository.saveShoppingListEntry(
      ShoppingListEntry(
        id: item.shoppingListEntryId < 0 ? null : item.shoppingListEntryId,
        productFamilyId: item.productFamilyId,
        productItemId: item.sourceProductItemId,
        quantity: nextUnits.toDouble(),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping list')),
      body: FutureBuilder<List<OptimizedShoppingGroup>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final groups = snapshot.data ?? const [];
          if (groups.isEmpty) {
            return const Center(child: Text('No optimized items yet'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(group.supermarketName),
                subtitle: Text(
                  'Estimated total: €${group.totalEstimatedCost.toStringAsFixed(2)}',
                ),
                children: group.items.map((item) {
                  final checked =
                      _boughtEntries.contains(item.shoppingListEntryId);
                  final units = item.quantity.round();
                  return ListTile(
                    dense: true,
                    leading: Checkbox(
                      value: checked,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _boughtEntries.add(item.shoppingListEntryId);
                          } else {
                            _boughtEntries.remove(item.shoppingListEntryId);
                          }
                        });
                      },
                    ),
                    title: Text(item.productFamilyName),
                    subtitle: Text(
                      '${item.bestItem.name} · €/u ${item.bestItem.pricePerQuantity.toStringAsFixed(2)} · est. €${item.estimatedCost.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: units <= 0
                              ? null
                              : () => _updateQuantity(item, -1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('$units'),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _updateQuantity(item, 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
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
