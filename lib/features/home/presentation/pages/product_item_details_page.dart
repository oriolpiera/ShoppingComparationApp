import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../persistence/domain/entities/product_item.dart';
import '../product_family_details_action.dart';
import '../product_family_presentation_helpers.dart';

/// Maps the device locale to the appropriate Open Food Facts subdomain.
///
/// Falls back to [world] for locales without a dedicated subdomain.
String _offSubdomain(Locale locale) {
  switch (locale.languageCode) {
    case 'ca':
      return 'es-ca';
    case 'es':
      return 'es';
    case 'eu':
      return 'es-eu';
    case 'gl':
      return 'es-gl';
    case 'fr':
      return 'fr';
    case 'de':
      return 'de';
    case 'it':
      return 'it';
    case 'nl':
      return 'nl';
    case 'pt':
      return 'pt';
    case 'pl':
      return 'pl';
    default:
      return 'world';
  }
}

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
          _barcodeRow(context),
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

  Widget _barcodeRow(BuildContext context) {
    final barcode = item.barcode;

    if (barcode == null || barcode.trim().isEmpty) {
      return const DetailRow(label: 'Barcode', value: '—');
    }

    final locale = Localizations.localeOf(context);
    final uri = Uri.parse(
      'https://${_offSubdomain(locale)}.openfoodfacts.org/product/$barcode',
    );
    final theme = Theme.of(context);

    return DetailRow(
      label: 'Barcode',
      value: barcode,
      widgetValue: GestureDetector(
        onTap: () async {
          try {
            final launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open Open Food Facts page'),
                ),
              );
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open Open Food Facts page'),
                ),
              );
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              barcode,
              style: TextStyle(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
