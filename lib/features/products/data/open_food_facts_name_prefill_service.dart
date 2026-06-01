import 'dart:convert';
import 'dart:io';

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

  Future<String?> tryGetProductNameByBarcode(String barcode) async {
    final prefill = await tryGetProductPrefillByBarcode(barcode);
    return prefill?.productName;
  }

  Future<OpenFoodFactsProductPrefill?> tryGetProductPrefillByBarcode(
    String barcode,
  ) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;

    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$normalizedBarcode',
      {'fields': 'product_name,brands,quantity'},
    );

    try {
      final body = await _getRequest(uri);
      if (body == null || body.isEmpty) return null;

      return parseProductPrefillFromResponse(body);
    } catch (_) {
      return null;
    }
  }

  String? parseProductNameFromResponse(String body) {
    return parseProductPrefillFromResponse(body)?.productName;
  }

  OpenFoodFactsProductPrefill? parseProductPrefillFromResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final status = decoded['status'];
      if (status != 1) return null;

      final product = decoded['product'];
      if (product is! Map<String, dynamic>) return null;

      final productName = _normalizeString(product['product_name']);
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

  static Future<String?> _defaultGetRequest(Uri uri) async {
    const requestTimeout = Duration(seconds: 4);
    final client = HttpClient();
    client.connectionTimeout = requestTimeout;
    try {
      return await (() async {
        final request = await client.getUrl(uri);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set(
          HttpHeaders.userAgentHeader,
          'ShoppingComparationApp/1.0 (barcode metadata enrichment)',
        );

        final response = await request.close();

        if (response.statusCode < 200 || response.statusCode >= 300) {
          return null;
        }

        return utf8.decoder.bind(response).join();
      })().timeout(requestTimeout);
    } finally {
      client.close(force: true);
    }
  }
}

class _QuantityHint {
  const _QuantityHint(this.quantity, this.unit);

  final double quantity;
  final String unit;
}
