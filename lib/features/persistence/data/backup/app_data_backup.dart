import 'dart:convert';

class AppDataBackup {
  static const int currentSchemaVersion = 1;

  const AppDataBackup({
    required this.schemaVersion,
    required this.exportedAt,
    required this.supermarkets,
    required this.productFamilies,
    required this.catalogProducts,
    required this.priceRecords,
    required this.shoppingListEntries,
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final List<BackupSupermarket> supermarkets;
  final List<BackupProductFamily> productFamilies;
  final List<BackupCatalogProduct> catalogProducts;
  final List<BackupPriceRecord> priceRecords;
  final List<BackupShoppingListEntry> shoppingListEntries;

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'supermarkets': supermarkets.map((row) => row.toJson()).toList(),
      'productFamilies': productFamilies.map((row) => row.toJson()).toList(),
      'catalogProducts': catalogProducts.map((row) => row.toJson()).toList(),
      'priceRecords': priceRecords.map((row) => row.toJson()).toList(),
      'shoppingListEntries':
          shoppingListEntries.map((row) => row.toJson()).toList(),
    };
  }

  static AppDataBackup fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup file must contain a JSON object.');
    }
    return fromJson(decoded);
  }

  static AppDataBackup fromJson(Map<String, dynamic> json) {
    final schemaVersion = _readInt(json, 'schemaVersion');
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported backup schema version: $schemaVersion.',
      );
    }

    final backup = AppDataBackup(
      schemaVersion: schemaVersion,
      exportedAt: _readDateTime(json, 'exportedAt'),
      supermarkets: _readList(json, 'supermarkets', BackupSupermarket.fromJson),
      productFamilies: _readList(
        json,
        'productFamilies',
        BackupProductFamily.fromJson,
      ),
      catalogProducts: _readList(
        json,
        'catalogProducts',
        BackupCatalogProduct.fromJson,
      ),
      priceRecords: _readList(json, 'priceRecords', BackupPriceRecord.fromJson),
      shoppingListEntries: _readList(
        json,
        'shoppingListEntries',
        BackupShoppingListEntry.fromJson,
      ),
    );

    backup._validateReferences();
    return backup;
  }

  void _validateReferences() {
    _ensureUniqueIds(supermarkets.map((row) => row.id), 'supermarkets');
    _ensureUniqueIds(productFamilies.map((row) => row.id), 'productFamilies');
    _ensureUniqueIds(catalogProducts.map((row) => row.id), 'catalogProducts');
    _ensureUniqueIds(priceRecords.map((row) => row.id), 'priceRecords');
    _ensureUniqueIds(
      shoppingListEntries.map((row) => row.id),
      'shoppingListEntries',
    );

    final supermarketIds = supermarkets.map((row) => row.id).toSet();
    final familyIds = productFamilies.map((row) => row.id).toSet();
    final catalogProductIds = catalogProducts.map((row) => row.id).toSet();

    for (final row in catalogProducts) {
      if (!familyIds.contains(row.productFamilyId)) {
        throw FormatException(
          'Catalog product ${row.id} references missing family ${row.productFamilyId}.',
        );
      }
    }

    for (final row in priceRecords) {
      if (!catalogProductIds.contains(row.catalogProductId)) {
        throw FormatException(
          'Price record ${row.id} references missing catalog product ${row.catalogProductId}.',
        );
      }
      if (!supermarketIds.contains(row.supermarketId)) {
        throw FormatException(
          'Price record ${row.id} references missing supermarket ${row.supermarketId}.',
        );
      }
    }

    for (final row in shoppingListEntries) {
      if (!familyIds.contains(row.productFamilyId)) {
        throw FormatException(
          'Shopping list entry ${row.id} references missing family ${row.productFamilyId}.',
        );
      }
    }
  }
}

class BackupSupermarket {
  const BackupSupermarket({
    required this.id,
    required this.name,
    required this.address,
    required this.isActive,
  });

  final int id;
  final String name;
  final String? address;
  final bool isActive;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'isActive': isActive,
      };

  static BackupSupermarket fromJson(Map<String, dynamic> json) {
    return BackupSupermarket(
      id: _readInt(json, 'id'),
      name: _readString(json, 'name'),
      address: _readNullableString(json, 'address'),
      isActive: _readBool(json, 'isActive'),
    );
  }
}

class BackupProductFamily {
  const BackupProductFamily({
    required this.id,
    required this.name,
    required this.isActive,
    required this.shoppingUnit,
    required this.purchaseMode,
  });

  final int id;
  final String name;
  final bool isActive;
  final String? shoppingUnit;
  final String? purchaseMode;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        'shoppingUnit': shoppingUnit,
        'purchaseMode': purchaseMode,
      };

  static BackupProductFamily fromJson(Map<String, dynamic> json) {
    return BackupProductFamily(
      id: _readInt(json, 'id'),
      name: _readString(json, 'name'),
      isActive: _readBool(json, 'isActive'),
      shoppingUnit: _readNullableString(json, 'shoppingUnit'),
      purchaseMode: _readNullableString(json, 'purchaseMode'),
    );
  }
}

class BackupCatalogProduct {
  const BackupCatalogProduct({
    required this.id,
    required this.name,
    required this.isActive,
    required this.productFamilyId,
    required this.barcode,
    required this.packageQuantityAmount,
    required this.packageQuantityUnit,
    required this.normalizedMeasurementUnit,
    required this.identityKey,
  });

  final int id;
  final String name;
  final bool isActive;
  final int productFamilyId;
  final String? barcode;
  final double? packageQuantityAmount;
  final String? packageQuantityUnit;
  final String? normalizedMeasurementUnit;
  final String identityKey;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        'productFamilyId': productFamilyId,
        'barcode': barcode,
        'packageQuantityAmount': packageQuantityAmount,
        'packageQuantityUnit': packageQuantityUnit,
        'normalizedMeasurementUnit': normalizedMeasurementUnit,
        'identityKey': identityKey,
      };

  static BackupCatalogProduct fromJson(Map<String, dynamic> json) {
    return BackupCatalogProduct(
      id: _readInt(json, 'id'),
      name: _readString(json, 'name'),
      isActive: _readBool(json, 'isActive'),
      productFamilyId: _readInt(json, 'productFamilyId'),
      barcode: _readNullableString(json, 'barcode'),
      packageQuantityAmount: _readNullableDouble(json, 'packageQuantityAmount'),
      packageQuantityUnit: _readNullableString(json, 'packageQuantityUnit'),
      normalizedMeasurementUnit:
          _readNullableString(json, 'normalizedMeasurementUnit'),
      identityKey: _readString(json, 'identityKey'),
    );
  }
}

class BackupPriceRecord {
  const BackupPriceRecord({
    required this.id,
    required this.catalogProductId,
    required this.supermarketId,
    required this.price,
    required this.observedAt,
    required this.isActive,
  });

  final int id;
  final int catalogProductId;
  final int supermarketId;
  final double price;
  final DateTime observedAt;
  final bool isActive;

  Map<String, Object?> toJson() => {
        'id': id,
        'catalogProductId': catalogProductId,
        'supermarketId': supermarketId,
        'price': price,
        'observedAt': observedAt.toIso8601String(),
        'isActive': isActive,
      };

  static BackupPriceRecord fromJson(Map<String, dynamic> json) {
    return BackupPriceRecord(
      id: _readInt(json, 'id'),
      catalogProductId: _readInt(json, 'catalogProductId'),
      supermarketId: _readInt(json, 'supermarketId'),
      price: _readDouble(json, 'price'),
      observedAt: _readDateTime(json, 'observedAt'),
      isActive: _readBool(json, 'isActive'),
    );
  }
}

class BackupShoppingListEntry {
  const BackupShoppingListEntry({
    required this.id,
    required this.productFamilyId,
    required this.quantity,
  });

  final int id;
  final int productFamilyId;
  final int quantity;

  Map<String, Object?> toJson() => {
        'id': id,
        'productFamilyId': productFamilyId,
        'quantity': quantity,
      };

  static BackupShoppingListEntry fromJson(Map<String, dynamic> json) {
    return BackupShoppingListEntry(
      id: _readInt(json, 'id'),
      productFamilyId: _readInt(json, 'productFamilyId'),
      quantity: _readInt(json, 'quantity'),
    );
  }
}

List<T> _readList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) parser,
) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected "$key" to be a JSON array.');
  }

  return value.map((entry) {
    if (entry is! Map<String, dynamic>) {
      throw FormatException('Expected "$key" entries to be JSON objects.');
    }
    return parser(entry);
  }).toList();
}

void _ensureUniqueIds(Iterable<int> ids, String collectionName) {
  final seen = <int>{};
  for (final id in ids) {
    if (!seen.add(id)) {
      throw FormatException('Duplicate id $id found in $collectionName.');
    }
  }
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Expected "$key" to be an integer.');
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw FormatException('Expected "$key" to be a number.');
}

double? _readNullableDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is num) return value.toDouble();
  throw FormatException('Expected "$key" to be a number or null.');
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Expected "$key" to be a non-empty string.');
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Expected "$key" to be a string or null.');
}

bool _readBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Expected "$key" to be a boolean.');
}

DateTime _readDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Expected "$key" to be an ISO-8601 string.');
  }
  return DateTime.parse(value);
}
