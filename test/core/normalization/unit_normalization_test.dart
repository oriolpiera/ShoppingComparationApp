import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_comparation_app/core/normalization/unit_normalization.dart';

void main() {
  group('unit type normalization', () {
    test('display keeps canonical unit labels', () {
      expect(normalizeUnitTypeForDisplay(' l '), 'L');
      expect(normalizeUnitTypeForDisplay('kg'), 'kg');
      expect(normalizeUnitTypeForDisplay('ml'), 'ml');
      expect(normalizeUnitTypeForDisplay('unit'), 'unit');
    });

    test('comparison canonicalizes known aliases', () {
      expect(normalizeUnitTypeForComparison(' L '), 'l');
      expect(normalizeUnitTypeForComparison('Kg'), 'kg');
      expect(normalizeUnitTypeForComparison('piece'), 'unit');
    });

    test('storage uses canonical persisted values', () {
      expect(normalizeUnitTypeForStorage(' L '), 'L');
      expect(normalizeUnitTypeForStorage(' kg '), 'kg');
      expect(normalizeUnitTypeForStorage('piece'), 'unit');
    });

    test('supports unit as a first-class display/storage value', () {
      expect(normalizeUnitTypeForDisplay('unit'), 'unit');
      expect(normalizeUnitTypeForComparison('piece'), 'unit');
      expect(normalizeUnitTypeForStorage('piece'), 'unit');
      expect(normalizeUnitTypeForDisplay('g'), 'g');
      expect(normalizeUnitTypeForDisplay('ml'), 'ml');
    });

    test('canonicalizes family semantics values', () {
      expect(normalizeShoppingUnitForStorage('kg'), 'kilogram');
      expect(normalizeShoppingUnitForStorage('L'), 'liter');
      expect(normalizeShoppingUnitForStorage('unit'), 'piece');
      expect(normalizePurchaseModeForStorage('fresh'), 'weighted');
    });

    test('infers piece semantics for count-based items', () {
      expect(inferShoppingUnitFromUnitType('unit'), 'piece');
      expect(inferPurchaseModeFromUnitType('unit'), 'piece');
    });
  });
}
