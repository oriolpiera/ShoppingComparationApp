import 'package:flutter/material.dart';

import '../../../core/normalization/unit_normalization.dart';
import '../../persistence/domain/entities/barcode_match_result.dart';
import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/scanned_price_registration_result.dart';
import '../../persistence/domain/repositories/persistence_repository.dart';
import '../../supermarkets/data/models/supermarket.dart';
import '../data/open_food_facts_name_prefill_service.dart';
import '../data/open_prices_price_prefill_service.dart';
import '../application/family_lookup.dart';
import '../domain/validation/product_item_validation.dart';
import 'product_item_capture_form_support.dart';

class BarcodeMatchesPage extends StatefulWidget {
  const BarcodeMatchesPage({
    super.key,
    required this.repository,
    required this.barcode,
    required this.namePrefillService,
    required this.pricePrefillService,
  });

  final BarcodeLookupRepository repository;
  final String barcode;
  final OpenFoodFactsNamePrefillService namePrefillService;
  final OpenPricesPricePrefillService pricePrefillService;

  @override
  State<BarcodeMatchesPage> createState() => _BarcodeMatchesPageState();
}

class _BarcodeMatchesPageState extends State<BarcodeMatchesPage> {
  late Future<_BarcodeLookupData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BarcodeLookupData> _load() async {
    final matches = await widget.repository.findCurrentActiveByBarcode(
      widget.barcode,
    );

    if (matches.isNotEmpty) {
      return _BarcodeLookupData(matches: matches);
    }

    final metadataPrefillFuture =
        widget.namePrefillService.tryGetProductPrefillByBarcode(
      widget.barcode,
      preferredLanguageCodes: _preferredOffLanguageCodes(),
    );
    final pricePrefillFuture =
        widget.pricePrefillService.tryGetPricePrefillByBarcode(widget.barcode);
    final prefill = await metadataPrefillFuture;
    final pricePrefill = await pricePrefillFuture;
    return _BarcodeLookupData(
      matches: matches,
      prefilledName: prefill?.productName,
      prefilledFamilySuggestion: prefill?.familySuggestion,
      prefilledQuantity: prefill?.packageQuantityHint,
      prefilledUnitType: prefill?.packageUnitHint,
      prefilledPrice: pricePrefill?.price,
    );
  }

  List<String> _preferredOffLanguageCodes() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return [locale.languageCode];
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _createProductItem(_BarcodeLookupData lookupData) async {
    final latest = lookupData.matches.isEmpty ? null : lookupData.matches.first;
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
        families: data.families,
        supermarkets: data.supermarkets,
        lastUsedSupermarketId: data.lastUsedSupermarketId,
        prefilledName: latest?.catalogProduct.name ?? lookupData.prefilledName,
        prefilledFamily:
            latest?.familyName ?? lookupData.prefilledFamilySuggestion,
        isPrefilledFamilyFromOff:
            latest == null && lookupData.prefilledFamilySuggestion != null,
        prefilledPrice: lookupData.prefilledPrice,
        prefilledQuantity: lookupData.prefilledQuantity,
        prefilledUnitType: lookupData.prefilledUnitType,
      ),
    );

    if (!mounted || result == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message ?? 'Done')));
    if (result.created) {
      Navigator.of(context).pop(true);
    } else {
      await _refresh();
    }
  }

  Future<_BarcodeCreateData> _loadCreateData() async {
    final families = await widget.repository.getProductFamilies(
      onlyActive: true,
    );
    final supermarkets = await widget.repository.getSupermarkets(
      onlyActive: true,
    );
    final lastUsedSupermarketId =
        await widget.repository.getLastUsedSupermarketId();
    return _BarcodeCreateData(
      families: families,
      supermarkets: supermarkets,
      lastUsedSupermarketId: lastUsedSupermarketId,
    );
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
                      'No current active Product Items for this barcode.',
                    ),
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
                    return ListTile(
                      title: Text(
                        '${match.supermarketName} · ${match.catalogProduct.name}',
                      ),
                      subtitle: Text(
                        '€${match.priceRecord.price.toStringAsFixed(2)} · ${match.quantity} ${match.unitType} · ${match.pricePerQuantity.toStringAsFixed(2)} €/${match.unitType}',
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

class _RegisterScannedPriceSheet extends StatefulWidget {
  const _RegisterScannedPriceSheet({
    required this.repository,
    required this.barcode,
    required this.families,
    required this.supermarkets,
    required this.lastUsedSupermarketId,
    this.prefilledName,
    this.prefilledFamily,
    this.isPrefilledFamilyFromOff = false,
    this.prefilledPrice,
    this.prefilledQuantity,
    this.prefilledUnitType,
  });

  final BarcodeLookupRepository repository;
  final String barcode;
  final List<ProductFamily> families;
  final List<Supermarket> supermarkets;
  final int? lastUsedSupermarketId;
  final String? prefilledName;
  final String? prefilledFamily;
  final bool isPrefilledFamilyFromOff;
  final double? prefilledPrice;
  final double? prefilledQuantity;
  final String? prefilledUnitType;

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
    _familyController = TextEditingController(
      text: widget.prefilledFamily ?? '',
    );
    _priceController = TextEditingController(
      text: widget.prefilledPrice?.toStringAsFixed(2) ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.prefilledQuantity?.toString() ?? '1',
    );
    _unitType = normalizeUnitTypeForDisplay(widget.prefilledUnitType ?? 'kg');

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
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final refreshedFamilies = await widget.repository.getProductFamilies(
      onlyActive: true,
    );
    final selectedFamily = findExistingFamilyByName(
          families: refreshedFamilies,
          familyName: family,
        ) ??
        ProductFamily(name: family);
    final familyError = validateItemForFamily(
      family: selectedFamily,
      quantity: quantity,
      unitType: _unitType,
    );
    if (familyError != null) {
      if (mounted) {
        showValidationSnackBar(context, familyError);
      }
      return;
    }

    final storedUnitType = normalizeUnitTypeForStorage(_unitType);

    final result = await widget.repository.registerScannedPrice(
      barcode: widget.barcode,
      productName: name,
      familyName: family,
      supermarketId: _supermarketId,
      price: price,
      quantity: quantity,
      unitType: storedUnitType,
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
              buildFamilyAutocompleteField(
                familyController: _familyController,
                families: widget.families,
                helperText: widget.isPrefilledFamilyFromOff
                    ? 'Suggested from Open Food Facts. Please confirm or edit.'
                    : null,
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
                  DropdownMenuItem(value: 'unit', child: Text('unit')),
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

class _BarcodeLookupData {
  const _BarcodeLookupData({
    required this.matches,
    this.prefilledName,
    this.prefilledFamilySuggestion,
    this.prefilledPrice,
    this.prefilledQuantity,
    this.prefilledUnitType,
  });

  final List<BarcodeMatchResult> matches;
  final String? prefilledName;
  final String? prefilledFamilySuggestion;
  final double? prefilledPrice;
  final double? prefilledQuantity;
  final String? prefilledUnitType;
}

class _BarcodeCreateData {
  const _BarcodeCreateData({
    required this.families,
    required this.supermarkets,
    required this.lastUsedSupermarketId,
  });

  final List<ProductFamily> families;
  final List<Supermarket> supermarkets;
  final int? lastUsedSupermarketId;
}
