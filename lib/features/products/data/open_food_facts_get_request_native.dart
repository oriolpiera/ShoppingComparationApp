import 'dart:convert';
import 'dart:io';

Future<String?> openFoodFactsGetRequest(Uri uri) async {
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
