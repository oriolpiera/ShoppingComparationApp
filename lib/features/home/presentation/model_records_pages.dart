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

  void _refresh() => setState(() => _future = _load());

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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _openForm(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              await widget.repository.saveSupermarket(
                                Supermarket(
                                  id: item.id,
                                  name: item.name,
                                  address: item.address,
                                  isActive: false,
                                ),
                              );
                              _refresh();
                            },
                          ),
                        ],
                      ),
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

class ProductFamiliesPage extends StatelessWidget {
  const ProductFamiliesPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  Widget build(BuildContext context) {
    return _RecordsScaffold<ProductFamily>(
      title: 'Product families',
      future: repository.getProductFamilies(onlyActive: false),
      itemBuilder: (item) =>
          'ID ${item.id ?? '-'} · ${item.name} · active: ${item.isActive}',
    );
  }
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
    return _ProductContext(items, families, supermarkets);
  }

  void _refresh() => setState(() => _future = _load());

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

                final query = _queryController.text.toLowerCase().trim();
                final filtered = data.items
                    .where((i) => i.isActive)
                    .where((i) =>
                        query.isEmpty || i.name.toLowerCase().contains(query))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No products'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(
                        '€${item.price.toStringAsFixed(2)} · ${item.quantity} ${item.unitType} · €/u ${item.pricePerQuantity.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _openForm(item, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
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
                              _refresh();
                            },
                          ),
                        ],
                      ),
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
    if (data.families.isEmpty || data.supermarkets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Need at least one family and supermarket first'),
          ),
        );
      }
      return;
    }

    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(
      text: item == null ? '' : item.price.toString(),
    );
    final quantityController = TextEditingController(
      text: item == null ? '' : item.quantity.toString(),
    );
    final unitTypeController =
        TextEditingController(text: item?.unitType ?? 'kg');

    var familyId = item?.productFamilyId ?? data.families.first.id!;
    var supermarketId = item?.supermarketId ?? data.supermarkets.first.id!;

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
                DropdownButtonFormField<int>(
                  initialValue: familyId,
                  decoration: const InputDecoration(labelText: 'Family'),
                  items: data.families
                      .map((f) => DropdownMenuItem<int>(
                            value: f.id,
                            child: Text(f.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => familyId = value);
                    }
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
                TextField(
                  controller: unitTypeController,
                  decoration: const InputDecoration(labelText: 'Unit type'),
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
    final unitType = unitTypeController.text.trim();

    if (save == true &&
        name.isNotEmpty &&
        price != null &&
        quantity != null &&
        unitType.isNotEmpty) {
      await widget.repository.saveProductItem(
        ProductItem(
          id: item?.id,
          name: name,
          isActive: true,
          productFamilyId: familyId,
          supermarketId: supermarketId,
          price: price,
          quantity: quantity,
          unitType: unitType,
          pricePerQuantity: quantity == 0 ? 0 : price / quantity,
          dateAdded: item?.dateAdded ?? DateTime.now(),
          isCurrentPrice: true,
          barcode: item?.barcode,
        ),
      );
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

  void _refresh() => setState(() => _future = _load());

  Future<void> _updateQuantity(OptimizedShoppingItem item, double delta) async {
    final next = (item.quantity + delta).clamp(0, 9999).toDouble();
    await widget.repository.saveShoppingListEntry(
      ShoppingListEntry(
        id: item.shoppingListEntryId < 0 ? null : item.shoppingListEntryId,
        productFamilyId: item.productFamilyId,
        productItemId: item.sourceProductItemId,
        quantity: next,
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
                          onPressed: () => _updateQuantity(item, -1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text(item.quantity.toStringAsFixed(0)),
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

class _ProductContext {
  const _ProductContext(this.items, this.families, this.supermarkets);

  final List<ProductItem> items;
  final List<ProductFamily> families;
  final List<Supermarket> supermarkets;
}

class _RecordsScaffold<T> extends StatelessWidget {
  const _RecordsScaffold({
    required this.title,
    required this.future,
    required this.itemBuilder,
  });

  final String title;
  final Future<List<T>> future;
  final String Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<T>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? const [];
          if (data.isEmpty) {
            return const Center(child: Text('No records yet'));
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => ListTile(
              dense: true,
              title: Text(itemBuilder(data[index])),
            ),
          );
        },
      ),
    );
  }
}
