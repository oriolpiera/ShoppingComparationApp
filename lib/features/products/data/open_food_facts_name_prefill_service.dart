import 'dart:convert';

import 'remote_get_request_native.dart'
    if (dart.library.js_interop) 'remote_get_request_web.dart';

typedef OpenFoodFactsGetRequest = Future<String?> Function(Uri uri);

class OpenFoodFactsProductPrefill {
  const OpenFoodFactsProductPrefill({
    this.productName,
    this.brand,
    this.packageQuantityHint,
    this.packageUnitHint,
    this.familySuggestion,
  });

  final String? productName;
  final String? brand;
  final double? packageQuantityHint;
  final String? packageUnitHint;
  final String? familySuggestion;
}

class OpenFoodFactsNamePrefillService {
  OpenFoodFactsNamePrefillService({OpenFoodFactsGetRequest? getRequest})
      : _getRequest = getRequest ?? _defaultGetRequest;

  final OpenFoodFactsGetRequest _getRequest;

  Future<String?> tryGetProductNameByBarcode(
    String barcode, {
    Iterable<String> preferredLanguageCodes = const [],
  }) async {
    final prefill = await tryGetProductPrefillByBarcode(
      barcode,
      preferredLanguageCodes: preferredLanguageCodes,
    );
    return prefill?.productName;
  }

  Future<OpenFoodFactsProductPrefill?> tryGetProductPrefillByBarcode(
    String barcode, {
    Iterable<String> preferredLanguageCodes = const [],
  }) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;
    final normalizedLanguageCodes = _normalizeLanguageCodes(
      preferredLanguageCodes,
    );
    final fields = <String>[
      'product_name',
      for (final code in normalizedLanguageCodes) 'product_name_$code',
      'brands',
      'quantity',
    ];

    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$normalizedBarcode',
      {'fields': fields.join(',')},
    );

    try {
      final body = await _getRequest(uri);
      if (body == null || body.isEmpty) return null;

      return parseProductPrefillFromResponse(
        body,
        preferredLanguageCodes: normalizedLanguageCodes,
      );
    } catch (_) {
      return null;
    }
  }

  String? parseProductNameFromResponse(
    String body, {
    Iterable<String> preferredLanguageCodes = const [],
  }) {
    return parseProductPrefillFromResponse(
      body,
      preferredLanguageCodes: preferredLanguageCodes,
    )?.productName;
  }

  OpenFoodFactsProductPrefill? parseProductPrefillFromResponse(
    String body, {
    Iterable<String> preferredLanguageCodes = const [],
  }) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final status = decoded['status'];
      if (status != 1) return null;

      final product = decoded['product'];
      if (product is! Map<String, dynamic>) return null;

      final productName = _resolveProductName(
        product,
        preferredLanguageCodes: preferredLanguageCodes,
      );
      final brand = _normalizeString(
        product['brands'],
      )?.split(',').first.trim();
      final quantityRaw = _normalizeString(product['quantity']);
      final quantityHint = _parseQuantityHint(quantityRaw);
      final familySuggestion = _buildFamilySuggestion(
        productName: productName,
        brand: brand,
      );

      if (productName == null &&
          brand == null &&
          quantityHint == null &&
          familySuggestion == null) {
        return null;
      }

      return OpenFoodFactsProductPrefill(
        productName: productName,
        brand: brand,
        packageQuantityHint: quantityHint?.quantity,
        packageUnitHint: quantityHint?.unit,
        familySuggestion: familySuggestion,
      );
    } on FormatException {
      return null;
    }
  }

  String? _buildFamilySuggestion({
    required String? productName,
    required String? brand,
  }) {
    final baseName = productName ?? brand;
    if (baseName == null) return null;

    final cleaned = baseName
        .replaceAll(
          RegExp(r'\b\d+[\d\s.,]*\s*(g|kg|ml|l|cl)\b', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned.isEmpty ? null : cleaned;
  }

  String? _resolveProductName(
    Map<String, dynamic> product, {
    required Iterable<String> preferredLanguageCodes,
  }) {
    for (final code in _normalizeLanguageCodes(preferredLanguageCodes)) {
      final localizedName = _normalizeString(product['product_name_$code']);
      if (localizedName != null) return localizedName;
    }

    return _normalizeString(product['product_name']);
  }

  List<String> _normalizeLanguageCodes(Iterable<String> codes) {
    final normalized = <String>[];
    for (final rawCode in codes) {
      final trimmed = rawCode.trim();
      if (trimmed.isEmpty) continue;
      final baseCode = trimmed.split(RegExp(r'[-_]')).first.toLowerCase();
      if (!RegExp(r'^[a-z]{2,3}$').hasMatch(baseCode)) continue;
      if (!normalized.contains(baseCode)) {
        normalized.add(baseCode);
      }
    }
    return normalized;
  }

  _QuantityHint? _parseQuantityHint(String? raw) {
    if (raw == null) return null;

    final match = RegExp(
      r'^(\d+(?:[\.,]\d+)?)\s*(kg|g|l|ml)\b',
      caseSensitive: false,
    ).firstMatch(raw.trim());
    if (match == null) return null;

    final amount = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    final unit = match.group(2)?.toLowerCase();
    if (amount == null || unit == null) return null;

    if (unit == 'g') {
      return _QuantityHint(amount / 1000, 'kg');
    }
    if (unit == 'ml') {
      return _QuantityHint(amount / 1000, 'L');
    }
    if (unit == 'kg') {
      return _QuantityHint(amount, 'kg');
    }
    if (unit == 'l') {
      return _QuantityHint(amount, 'L');
    }

    return null;
  }

  String? _normalizeString(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static Future<String?> _defaultGetRequest(Uri uri) => remoteGetRequest(uri);
}

class _QuantityHint {
  const _QuantityHint(this.quantity, this.unit);

  final double quantity;
  final String unit;
}
