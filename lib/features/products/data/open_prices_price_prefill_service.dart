import 'dart:convert';

import 'remote_get_request_native.dart'
    if (dart.library.js_interop) 'remote_get_request_web.dart';

typedef OpenPricesGetRequest = Future<String?> Function(Uri uri);

class OpenPricesPricePrefill {
  const OpenPricesPricePrefill({required this.price});

  final double price;
}

class OpenPricesPricePrefillService {
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
        if (price == null || observedAt == null) continue;

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
      return OpenPricesPricePrefill(price: price);
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
