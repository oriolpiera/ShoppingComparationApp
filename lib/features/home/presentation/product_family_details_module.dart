import 'package:flutter/material.dart';

import '../../../core/normalization/unit_normalization.dart';
import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/repositories/persistence_repository.dart';
import '../../products/presentation/product_item_capture_form_support.dart';
import '../application/product_family_comparison_module.dart';
import '../application/product_family_details_controller.dart';
import '../application/product_family_details_data.dart';
import 'pages/product_item_details_page.dart';
import 'product_family_details_action.dart';
import 'product_family_presentation_helpers.dart';

class ProductFamilyDetailsPage extends StatefulWidget {
  const ProductFamilyDetailsPage({
    super.key,
    required this.item,
    required this.repository,
  });

  final ProductFamily item;
  final PersistenceRepository repository;

  @override
  State<ProductFamilyDetailsPage> createState() =>
      _ProductFamilyDetailsPageState();
}

class _ProductFamilyDetailsPageState extends State<ProductFamilyDetailsPage> {
  late Future<ProductFamilyDetailsData> _future;
  late ProductFamilyDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProductFamilyDetailsController(
      repository: widget.repository,
      family: widget.item,
    );
    _future = _controller.loadData();
  }

  Future<void> _openItemDetails(
    ProductItem item,
    String familyName,
    String supermarketName,
  ) async {
    final action = await Navigator.of(context).push<ProductItemDetailsAction>(
      MaterialPageRoute(
        builder: (_) => ProductItemDetailsPage(
          item: item,
          familyName: familyName,
          supermarketName: supermarketName,
          formattedDateAdded: _formatDateAdded(context, item.dateAdded),
        ),
      ),
    );

    if (!mounted) return;

    if (action == ProductItemDetailsAction.edit) {
      await _editProductItem(item);
    } else if (action == ProductItemDetailsAction.delete) {
      await _controller.inactivateItem(item);
    } else {
      return;
    }

    setState(() {
      _future = _controller.loadData();
    });
  }

  Future<void> _editProductItem(ProductItem item) async {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    var unitType = normalizeUnitTypeForDisplay(item.unitType);

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
                    DropdownMenuItem(value: 'unit', child: Text('unit')),
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
      final error = await _controller.saveEditedItem(
        original: item,
        name: name,
        price: price,
        quantity: quantity,
        unitType: unitType,
      );

      if (error != null && mounted) {
        showValidationSnackBar(context, error);
        return;
      }
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
        final exists = entries.any(
          (entry) => entry.productFamilyId == familyId,
        );
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
                Navigator.pop(context, ProductFamilyDetailsAction.edit),
          ),
        ],
      ),
      body: FutureBuilder<ProductFamilyDetailsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data =
              snapshot.data ?? const ProductFamilyDetailsData([], {}, 0);
          final comparisonView = buildProductFamilyComparisonView(
            items: data.items,
            supermarketById: data.supermarketById,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DetailRow(label: 'Name', value: widget.item.name),
              DetailRow(
                label: 'Active',
                value: widget.item.isActive ? 'Yes' : 'No',
              ),
              DetailRow(
                label: 'Current active items count',
                value: '${comparisonView.items.length}',
              ),
              DetailRow(
                label: 'Best unit price',
                value: comparisonView.bestUnitPrice == null
                    ? '—'
                    : comparisonView.bestUnitPrice!.toStringAsFixed(2),
              ),
              const SizedBox(height: 16),
              const Text(
                'Product Items comparison',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (comparisonView.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No current active Product Items'),
                )
              else
                ...comparisonView.items.map((comparisonItem) {
                  final productItem = comparisonItem.productItem;
                  final supermarketName = comparisonItem.supermarketName;
                  final unitType = normalizeUnitTypeForDisplay(
                    productItem.unitType,
                  );

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
                        if (comparisonItem.hasInactiveSupermarket)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
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
                      comparisonItem.supermarketName,
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

                    final action = await showDialog<ProductFamilyDetailsAction>(
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
                              ProductFamilyDetailsAction.deleteKeepItems,
                            ),
                            child: const Text('Keep active items'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(
                              context,
                              ProductFamilyDetailsAction
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
                      ProductFamilyDetailsAction.deleteKeepItems,
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
