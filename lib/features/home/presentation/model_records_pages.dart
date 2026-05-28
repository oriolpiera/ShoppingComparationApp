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
    final unitTypeController =
        TextEditingController(text: item?.unitType ?? 'kg');
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
    final familyName = familyController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final quantity = double.tryParse(quantityController.text.trim());
    final unitType = unitTypeController.text.trim();

    if (save == true &&
        name.isNotEmpty &&
        familyName.isNotEmpty &&
        price != null &&
        quantity != null &&
        unitType.isNotEmpty) {
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
