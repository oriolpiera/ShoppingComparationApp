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

    test('returns null when product not found', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final name = service.parseProductNameFromResponse('{"status":0}');

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
