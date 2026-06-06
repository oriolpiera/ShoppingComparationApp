import 'package:flutter/material.dart';

import '../../../persistence/domain/entities/product_family.dart';
import '../../../persistence/domain/entities/product_item.dart';
import '../../../persistence/domain/entities/shopping_list_entry.dart';
import '../../../persistence/domain/repositories/shopping_list_repository.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key, required this.repository});

  final ShoppingListRepository repository;

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
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
    final optimization =
        await widget.repository.getOptimizedShoppingNeedEntries();
    final activeFamilies = await widget.repository.getActiveShoppingFamilies();

    final sortedGroups = optimization.groups
        .map(
          (group) => MapEntry(
            group.supermarketName,
            group.entries
                .map(
                  (entry) => _ShoppingRow(
                    entryId: entry.shoppingListEntryId,
                    familyId: entry.productFamilyId,
                    familyName: entry.productFamilyName,
                    quantity: entry.quantity,
                    bestItem: entry.bestItem,
                    estimatedCost: entry.estimatedCost,
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    final pendingRows = optimization.pendingEntries
        .map(
          (entry) => _ShoppingRow(
            entryId: entry.shoppingListEntryId,
            familyId: entry.productFamilyId,
            familyName: entry.productFamilyName,
            quantity: entry.quantity,
            isInactiveFamily: entry.isInactiveFamily,
          ),
        )
        .toList();

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

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _updateQuantity(_ShoppingRow row, int delta) async {
    final nextUnits = (row.quantity + delta).clamp(0, 9999);
    await widget.repository.saveShoppingNeedEntry(
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
                    .map(
                      (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
                    )
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
      await widget.repository.addOrIncrementShoppingNeedEntry(
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
      await widget.repository.deleteShoppingNeedEntries(
        _selectedEntryIds.toList(),
      );
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
          ? Checkbox(value: isSelected, onChanged: (_) => _onTapRow(row))
          : Checkbox(value: isBought, onChanged: (_) => _toggleBought(row)),
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
            : '${row.bestItem!.name} · €/u ${row.bestItem!.pricePerQuantity.toStringAsFixed(2)} · est. €${row.estimatedCost.toStringAsFixed(2)}',
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
            title: Text(
              _selectionMode
                  ? '${_selectedEntryIds.length} selected'
                  : 'Shopping list',
            ),
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
                          sum + (row.bestItem == null ? 0 : row.estimatedCost),
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
                      title: Text(
                        'Pending / inactive',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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
    this.estimatedCost = 0,
    this.bestItem,
    this.isInactiveFamily = false,
  });

  final int entryId;
  final int familyId;
  final String familyName;
  final int quantity;
  final double estimatedCost;
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
