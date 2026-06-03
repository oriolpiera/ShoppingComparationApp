import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/products/data/open_prices_price_prefill_service.dart';

void main() {
  group('OpenPricesPricePrefillService', () {
    test('returns most recent price suggestion', () {
      final service =
          OpenPricesPricePrefillService(getRequest: (_) async => null);

      final prefill = service.parsePricePrefillFromResponse(
        '{"items":[{"price":0.76,"currency":"EUR","date":"2025-06-24","location":{"osm_display_name":"Paris"}},{"price":0.99,"currency":"EUR","date":"2026-04-07","location":{"osm_display_name":"Olot"}}]}',
      );

      expect(prefill, isNotNull);
      expect(prefill!.price, 0.99);
    });

    test('uses place as deterministic tie-breaker when dates match', () {
      final service =
          OpenPricesPricePrefillService(getRequest: (_) async => null);

      final prefill = service.parsePricePrefillFromResponse(
        '{"items":[{"price":1.20,"currency":"EUR","date":"2026-04-07","location":{"osm_display_name":"Paris"}},{"price":0.99,"currency":"EUR","date":"2026-04-07","location":{"osm_display_name":"Olot"}}]}',
      );

      expect(prefill, isNotNull);
      expect(prefill!.price, 0.99);
    });

    test('ignores non-EUR price suggestions', () {
      final service =
          OpenPricesPricePrefillService(getRequest: (_) async => null);

      final prefill = service.parsePricePrefillFromResponse(
        '{"items":[{"price":5.49,"currency":"USD","date":"2026-05-01","location":{"osm_display_name":"New York"}},{"price":0.99,"currency":"EUR","date":"2026-04-07","location":{"osm_display_name":"Olot"}}]}',
      );

      expect(prefill, isNotNull);
      expect(prefill!.price, 0.99);
    });

    test('returns null when no valid price rows exist', () {
      final service =
          OpenPricesPricePrefillService(getRequest: (_) async => null);

      final prefill = service.parsePricePrefillFromResponse(
        '{"items":[{"price":null,"currency":"EUR","date":"2026-04-07"},{"price":0.99,"currency":"EUR","date":null},{"price":1.99,"currency":"USD","date":"2026-05-01"}]}',
      );

      expect(prefill, isNull);
    });
  });
}
