import 'package:flutter/material.dart';

import '../../../../core/normalization/unit_normalization.dart';
import '../../../../core/scanner/mobile_scanner_port.dart';
import '../../../persistence/domain/entities/product_family.dart';
import '../../../persistence/domain/entities/product_item.dart';
import '../../../persistence/domain/repositories/persistence_repository.dart';
import '../../../products/application/family_lookup.dart';
import '../../../products/data/open_food_facts_name_prefill_service.dart';
import '../../../products/data/open_prices_price_prefill_service.dart';
import '../../../products/domain/validation/product_item_validation.dart';
import '../../../products/presentation/barcode_matches_page.dart';
import '../../../products/presentation/product_item_capture_form_support.dart';
import '../../../supermarkets/data/models/supermarket.dart';
import '../product_family_details_action.dart';
import 'product_item_details_page.dart';

class ProductItemsPage extends StatefulWidget {
  ProductItemsPage({
    super.key,
    required this.repository,
    OpenFoodFactsNamePrefillService? namePrefillService,
    OpenPricesPricePrefillService? pricePrefillService,
  })  : namePrefillService =
            namePrefillService ?? OpenFoodFactsNamePrefillService(),
        pricePrefillService =
            pricePrefillService ?? OpenPricesPricePrefillService();

  final ProductItemsRepository repository;
  final OpenFoodFactsNamePrefillService namePrefillService;
  final OpenPricesPricePrefillService pricePrefillService;

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
    final items = await widget.repository.getProductItems(
      onlyCurrentPrice: true,
    );
    final families = await widget.repository.getProductFamilies(
      onlyActive: true,
    );
    final supermarkets = await widget.repository.getSupermarkets(
      onlyActive: true,
    );
    final lastUsedSupermarketId =
        await widget.repository.getLastUsedSupermarketId();
    return _ProductContext(
      items,
      families,
      supermarkets,
      lastUsedSupermarketId,
    );
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
        builder: (_) => BarcodeMatchesPage(
          repository: widget.repository,
          barcode: barcode,
          namePrefillService: widget.namePrefillService,
          pricePrefillService: widget.pricePrefillService,
        ),
      ),
    );
    if (action == true) {
      _refresh();
    }
  }

  Future<void> _openFreshCaptureFlow() async {
    final data = await _future;
    if (!mounted) return;
    await _openForm(null, data, defaultFreshCapture: true);
  }

  RichText _buildMetricsText(BuildContext context, ProductItem item) {
    final unitType = normalizeUnitTypeForDisplay(item.unitType);
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
                    .map(
                      (i) => (
                        item: i,
                        familyName: familyNameById[i.productFamilyId] ??
                            'Unknown family',
                      ),
                    )
                    .where(
                      (entry) =>
                          query.isEmpty ||
                          entry.item.name.toLowerCase().contains(query) ||
                          entry.familyName.toLowerCase().contains(query),
                    )
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
                            .push<ProductItemDetailsAction>(
                          MaterialPageRoute(
                            builder: (_) => ProductItemDetailsPage(
                              item: item,
                              familyName: entry.familyName,
                              supermarketName: supermarketName,
                              formattedDateAdded: _formatDateAdded(
                                context,
                                item.dateAdded,
                              ),
                            ),
                          ),
                        );

                        if (!mounted) return;

                        if (action == ProductItemDetailsAction.edit) {
                          await _openForm(item, data);
                        } else if (action == ProductItemDetailsAction.delete) {
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
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('Product deleted')),
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
          FloatingActionButton.extended(
            heroTag: 'addFreshProductItem',
            onPressed: _openFreshCaptureFlow,
            icon: const Icon(Icons.add),
            label: const Text('Fresh'),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(
    ProductItem? item,
    _ProductContext data, {
    bool defaultFreshCapture = false,
  }) async {
    if (data.supermarkets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need at least one supermarket first')),
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
    var unitType = normalizeUnitTypeForDisplay(item?.unitType ?? 'kg');
    var isFreshCapture = item == null && defaultFreshCapture;
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
          title: Text(
            item == null
                ? (isFreshCapture ? 'Add fresh product' : 'Add product')
                : 'Edit product',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item == null)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: isFreshCapture,
                    title: const Text('Fresh product'),
                    subtitle: const Text(
                      'No barcode required. New kg/L families use weighted semantics.',
                    ),
                    onChanged: (value) {
                      setDialogState(() => isFreshCapture = value);
                    },
                  ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                buildFamilyAutocompleteField(
                  familyController: familyController,
                  families: data.families,
                ),
                DropdownButtonFormField<int>(
                  initialValue: supermarketId,
                  decoration: const InputDecoration(labelText: 'Supermarket'),
                  items: data.supermarkets
                      .map(
                        (s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.name),
                        ),
                      )
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
      final refreshedFamilies = await widget.repository.getProductFamilies(
        onlyActive: true,
      );
      final existingFamily = findExistingFamilyByName(
        families: refreshedFamilies,
        familyName: familyName,
      );
      final selectedFamily = existingFamily ?? ProductFamily(name: familyName);
      final familyError = validateItemForFamily(
        family: selectedFamily,
        quantity: quantity,
        unitType: unitType,
      );
      if (familyError != null) {
        if (mounted) {
          showValidationSnackBar(context, familyError);
        }
        return;
      }

      final storedUnitType = normalizeUnitTypeForStorage(unitType);

      if (item == null) {
        final capturePurchaseMode = isFreshCapture
            ? (normalizeUnitTypeForComparison(storedUnitType) == 'unit'
                ? 'piece'
                : 'weighted')
            : null;
        await widget.repository.saveQuickProductItem(
          productName: name,
          familyName: familyName,
          supermarketId: supermarketId,
          price: price,
          quantity: quantity,
          unitType: storedUnitType,
          purchaseMode: capturePurchaseMode,
        );
      } else {
        final resolvedFamilyId = existingFamily?.id ??
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
            unitType: storedUnitType,
            pricePerQuantity: quantity == 0 ? 0 : price / quantity,
            packageQuantityAmount: quantity,
            packageQuantityUnit: storedUnitType,
            normalizedMeasurementUnit: normalizeUnitTypeForComparison(
              storedUnitType,
            ),
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
