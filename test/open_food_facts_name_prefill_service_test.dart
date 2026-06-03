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

    test('prefers localized product_name for the requested language', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final prefill = service.parseProductPrefillFromResponse(
        '{"status":1,"product":{"product_name":"Paahdettu maap\u00e4hkin\u00e4","product_name_ca":"Cacauets pelats fregits sense sal","brands":"Alesto","quantity":"200 g"}}',
        preferredLanguageCodes: const ['ca-ES'],
      );

      expect(prefill, isNotNull);
      expect(prefill!.productName, 'Cacauets pelats fregits sense sal');
      expect(prefill.familySuggestion, 'Cacauets pelats fregits sense sal');
      expect(prefill.packageQuantityHint, 0.2);
      expect(prefill.packageUnitHint, 'kg');
    });

    test('falls back to product_name when localized field is missing', () {
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (_) async => null,
      );

      final prefill = service.parseProductPrefillFromResponse(
        '{"status":1,"product":{"product_name":"Default Name","brands":"Acme","quantity":"200 g"}}',
        preferredLanguageCodes: const ['ca'],
      );

      expect(prefill, isNotNull);
      expect(prefill!.productName, 'Default Name');
      expect(prefill.familySuggestion, 'Default Name');
      expect(prefill.packageQuantityHint, 0.2);
      expect(prefill.packageUnitHint, 'kg');
    });

    test('requests localized product_name fields for preferred languages',
        () async {
      Uri? requestedUri;
      final service = OpenFoodFactsNamePrefillService(
        getRequest: (uri) async {
          requestedUri = uri;
          return '{"status":1,"product":{"product_name":"Default Name","product_name_ca":"Nom localitzat"}}';
        },
      );

      final name = await service.tryGetProductNameByBarcode(
        '12345',
        preferredLanguageCodes: const ['ca_ES'],
      );

      expect(name, 'Nom localitzat');
      expect(requestedUri, isNotNull);
      expect(
        requestedUri!.queryParameters['fields'],
        contains('product_name_ca'),
      );
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
