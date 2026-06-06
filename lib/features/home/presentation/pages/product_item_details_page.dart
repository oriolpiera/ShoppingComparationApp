import 'package:flutter/material.dart';

import '../../../persistence/domain/entities/product_item.dart';
import '../product_family_details_action.dart';
import '../product_family_presentation_helpers.dart';

class ProductItemDetailsPage extends StatelessWidget {
  const ProductItemDetailsPage({
    super.key,
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
                Navigator.pop(context, ProductItemDetailsAction.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DetailRow(label: 'Name', value: item.name),
          DetailRow(label: 'Family', value: familyName),
          DetailRow(label: 'Supermarket', value: supermarketName),
          DetailRow(
            label: 'Price',
            value: '€${item.price.toStringAsFixed(2)}',
          ),
          DetailRow(label: 'Quantity', value: item.quantity.toString()),
          DetailRow(label: 'Unit type', value: item.unitType),
          DetailRow(
            label: 'Price per quantity',
            value: item.pricePerQuantity.toStringAsFixed(2),
          ),
          DetailRow(label: 'Date added', value: formattedDateAdded),
          DetailRow(label: 'Active', value: _yesNo(item.isActive)),
          DetailRow(
            label: 'Current price',
            value: _yesNo(item.isCurrentPrice),
          ),
          DetailRow(
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
                  content: const Text(
                    'This will mark the product as inactive.',
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
                Navigator.pop(context, ProductItemDetailsAction.delete);
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
