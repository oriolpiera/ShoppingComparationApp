import 'dart:convert';
import 'dart:io';

typedef OpenFoodFactsGetRequest = Future<String?> Function(Uri uri);

class OpenFoodFactsNamePrefillService {
  OpenFoodFactsNamePrefillService({
    OpenFoodFactsGetRequest? getRequest,
  }) : _getRequest = getRequest ?? _defaultGetRequest;

  final OpenFoodFactsGetRequest _getRequest;

  Future<String?> tryGetProductNameByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;

    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$normalizedBarcode',
      {'fields': 'product_name'},
    );

    try {
      final body = await _getRequest(uri);
      if (body == null || body.isEmpty) return null;

      return parseProductNameFromResponse(body);
    } catch (_) {
      return null;
    }
  }

  String? parseProductNameFromResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    final status = decoded['status'];
    if (status != 1) return null;

    final product = decoded['product'];
    if (product is! Map<String, dynamic>) return null;

    final productName = product['product_name'];
    if (productName is! String) return null;

    final normalizedName = productName.trim();
    if (normalizedName.isEmpty) return null;

    return normalizedName;
  }

  static Future<String?> _defaultGetRequest(Uri uri) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);
    try {
      final request = await client.getUrl(uri).timeout(
            const Duration(seconds: 4),
          );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader,
          'ShoppingComparationApp/1.0 (barcode name prefill)');

      final response = await request.close().timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      return await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 4));
    } finally {
      client.close(force: true);
    }
  }
}
