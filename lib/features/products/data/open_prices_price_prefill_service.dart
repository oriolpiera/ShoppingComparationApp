import 'dart:convert';

import 'remote_get_request_native.dart'
    if (dart.library.js_interop) 'remote_get_request_web.dart';

typedef OpenPricesGetRequest = Future<String?> Function(Uri uri);

class OpenPricesPricePrefill {
  const OpenPricesPricePrefill({
    required this.price,
    this.storeName,
    this.countryCode,
  });

  final double price;
  final String? storeName;
  final String? countryCode;
}

class OpenPricesPricePrefillService {
  static const _supportedCurrency = 'EUR';

  OpenPricesPricePrefillService({OpenPricesGetRequest? getRequest})
      : _getRequest = getRequest ?? _defaultGetRequest;

  final OpenPricesGetRequest _getRequest;

  Future<OpenPricesPricePrefill?> tryGetPricePrefillByBarcode(
    String barcode,
  ) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;

    final uri = Uri.https('prices.openfoodfacts.org', '/api/v1/prices', {
      'product_code': normalizedBarcode,
      'order_by': '-date',
    });

    try {
      final body = await _getRequest(uri);
      if (body == null || body.isEmpty) return null;

      return parsePricePrefillFromResponse(body);
    } catch (_) {
      return null;
    }
  }

  OpenPricesPricePrefill? parsePricePrefillFromResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final items = decoded['items'];
      if (items is! List) return null;

      Map<String, dynamic>? bestItem;
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final price = _parsePrice(item['price']);
        final observedAt = _parseObservedAt(item['date']);
        final currency = _parseCurrency(item['currency']);
        if (price == null ||
            observedAt == null ||
            currency != _supportedCurrency) {
          continue;
        }

        if (bestItem == null) {
          bestItem = item;
          continue;
        }

        final bestObservedAt = _parseObservedAt(bestItem['date']);
        final bestLocation = _locationSortValue(bestItem);
        final currentLocation = _locationSortValue(item);
        if (bestObservedAt == null ||
            observedAt.isAfter(bestObservedAt) ||
            (observedAt.isAtSameMomentAs(bestObservedAt) &&
                currentLocation.compareTo(bestLocation) < 0)) {
          bestItem = item;
        }
      }

      if (bestItem == null) return null;

      final price = _parsePrice(bestItem['price']);
      if (price == null) return null;

      final location = bestItem['location'];
      String? storeName;
      String? countryCode;
      if (location is Map<String, dynamic>) {
        final rawName = location['osm_name'];
        if (rawName is String && rawName.trim().isNotEmpty) {
          storeName = rawName.trim();
        }
        final rawCountry = location['osm_address_country_code'];
        if (rawCountry is String && rawCountry.trim().isNotEmpty) {
          countryCode = rawCountry.trim().toUpperCase();
        }
      }

      return OpenPricesPricePrefill(
        price: price,
        storeName: storeName,
        countryCode: countryCode,
      );
    } on FormatException {
      return null;
    }
  }

  double? _parsePrice(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _parseObservedAt(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  String? _parseCurrency(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim().toUpperCase();
    return normalized.isEmpty ? null : normalized;
  }

  String _locationSortValue(Map<String, dynamic> item) {
    final location = item['location'];
    if (location is Map<String, dynamic>) {
      final displayName = location['osm_display_name'];
      if (displayName is String && displayName.trim().isNotEmpty) {
        return displayName.trim().toLowerCase();
      }
      final name = location['osm_name'];
      if (name is String && name.trim().isNotEmpty) {
        return name.trim().toLowerCase();
      }
    }
    return '';
  }

  static Future<String?> _defaultGetRequest(Uri uri) => remoteGetRequest(uri);
}
