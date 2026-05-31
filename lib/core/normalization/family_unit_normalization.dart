String normalizeFamilySearchText(String value) {
  final lower = value.toLowerCase().trim();
  final buffer = StringBuffer();

  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_diacriticsMap[char] ?? char);
  }

  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String normalizeFamilyKey(String value) {
  return normalizeFamilySearchText(value)
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String normalizeUnitTypeForDisplay(String unitType) {
  if (isLiterUnit(unitType)) return 'L';
  return 'kg';
}

String normalizeUnitTypeForComparison(String unitType) {
  return unitType.trim().toLowerCase();
}

String normalizeUnitTypeForStorage(String unitType) {
  return unitType.trim();
}

bool isLiterUnit(String unitType) {
  return normalizeUnitTypeForComparison(unitType) == 'l';
}

const _diacriticsMap = <String, String>{
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};
