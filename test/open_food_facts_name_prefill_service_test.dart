import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/features/products/data/open_food_facts_name_prefill_service.dart';

void main() {
  group('OpenFoodFactsNamePrefillService', () {
    test('parses product_name when response status is 1', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final name = service.parseProductNameFromResponse(
        '{"status":1,"product":{"product_name":"Oat Drink"}}',
      );

      expect(name, 'Oat Drink');
    });

    test('parses metadata prefill when available', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final prefill = service.parseProductPrefillFromResponse(
        '{"status":1,"product":{"product_name":"Greek Yogurt 500 g","brands":"Acme","quantity":"500 g"}}',
      );

      expect(prefill, isNotNull);
      expect(prefill!.productName, 'Greek Yogurt 500 g');
      expect(prefill.familySuggestion, 'Greek Yogurt');
      expect(prefill.packageQuantityHint, 0.5);
      expect(prefill.packageUnitHint, 'kg');
    });

    test('returns null when product not found', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final name = service.parseProductNameFromResponse('{"status":0}');

      expect(name, isNull);
    });

    test('returns null when JSON is malformed', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final name = service.parseProductNameFromResponse('{bad json');

      expect(name, isNull);
    });

    test('returns null when request fails', () async {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => throw Exception('network'),
      );

      final name = await service.tryGetProductNameByBarcode('12345');

      expect(name, isNull);
    });
  });
}
