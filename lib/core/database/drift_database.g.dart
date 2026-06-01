// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $SupermarketTableTable extends SupermarketTable
    with TableInfo<$SupermarketTableTable, SupermarketTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupermarketTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adrecaMeta = const VerificationMeta('adreca');
  @override
  late final GeneratedColumn<String> adreca = GeneratedColumn<String>(
      'adreca', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actiuMeta = const VerificationMeta('actiu');
  @override
  late final GeneratedColumn<bool> actiu = GeneratedColumn<bool>(
      'actiu', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actiu" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, nom, adreca, actiu];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supermarket';
  @override
  VerificationContext validateIntegrity(
      Insertable<SupermarketTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('adreca')) {
      context.handle(_adrecaMeta,
          adreca.isAcceptableOrUnknown(data['adreca']!, _adrecaMeta));
    }
    if (data.containsKey('actiu')) {
      context.handle(
          _actiuMeta, actiu.isAcceptableOrUnknown(data['actiu']!, _actiuMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupermarketTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupermarketTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      adreca: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adreca']),
      actiu: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actiu'])!,
    );
  }

  @override
  $SupermarketTableTable createAlias(String alias) {
    return $SupermarketTableTable(attachedDatabase, alias);
  }
}

class SupermarketTableData extends DataClass
    implements Insertable<SupermarketTableData> {
  final int id;
  final String nom;
  final String? adreca;
  final bool actiu;
  const SupermarketTableData(
      {required this.id, required this.nom, this.adreca, required this.actiu});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || adreca != null) {
      map['adreca'] = Variable<String>(adreca);
    }
    map['actiu'] = Variable<bool>(actiu);
    return map;
  }

  SupermarketTableCompanion toCompanion(bool nullToAbsent) {
    return SupermarketTableCompanion(
      id: Value(id),
      nom: Value(nom),
      adreca:
          adreca == null && nullToAbsent ? const Value.absent() : Value(adreca),
      actiu: Value(actiu),
    );
  }

  factory SupermarketTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupermarketTableData(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      adreca: serializer.fromJson<String?>(json['adreca']),
      actiu: serializer.fromJson<bool>(json['actiu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'adreca': serializer.toJson<String?>(adreca),
      'actiu': serializer.toJson<bool>(actiu),
    };
  }

  SupermarketTableData copyWith(
          {int? id,
          String? nom,
          Value<String?> adreca = const Value.absent(),
          bool? actiu}) =>
      SupermarketTableData(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        adreca: adreca.present ? adreca.value : this.adreca,
        actiu: actiu ?? this.actiu,
      );
  SupermarketTableData copyWithCompanion(SupermarketTableCompanion data) {
    return SupermarketTableData(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      adreca: data.adreca.present ? data.adreca.value : this.adreca,
      actiu: data.actiu.present ? data.actiu.value : this.actiu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupermarketTableData(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('adreca: $adreca, ')
          ..write('actiu: $actiu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, adreca, actiu);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupermarketTableData &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.adreca == this.adreca &&
          other.actiu == this.actiu);
}

class SupermarketTableCompanion extends UpdateCompanion<SupermarketTableData> {
  final Value<int> id;
  final Value<String> nom;
  final Value<String?> adreca;
  final Value<bool> actiu;
  const SupermarketTableCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.adreca = const Value.absent(),
    this.actiu = const Value.absent(),
  });
  SupermarketTableCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.adreca = const Value.absent(),
    this.actiu = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<SupermarketTableData> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? adreca,
    Expression<bool>? actiu,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (adreca != null) 'adreca': adreca,
      if (actiu != null) 'actiu': actiu,
    });
  }

  SupermarketTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? nom,
      Value<String?>? adreca,
      Value<bool>? actiu}) {
    return SupermarketTableCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      adreca: adreca ?? this.adreca,
      actiu: actiu ?? this.actiu,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (adreca.present) {
      map['adreca'] = Variable<String>(adreca.value);
    }
    if (actiu.present) {
      map['actiu'] = Variable<bool>(actiu.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupermarketTableCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('adreca: $adreca, ')
          ..write('actiu: $actiu')
          ..write(')'))
        .toString();
  }
}

class $ProductFamilyTableTable extends ProductFamilyTable
    with TableInfo<$ProductFamilyTableTable, ProductFamilyTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductFamilyTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actiuMeta = const VerificationMeta('actiu');
  @override
  late final GeneratedColumn<bool> actiu = GeneratedColumn<bool>(
      'actiu', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actiu" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _shoppingUnitMeta =
      const VerificationMeta('shoppingUnit');
  @override
  late final GeneratedColumn<String> shoppingUnit = GeneratedColumn<String>(
      'shopping_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseModeMeta =
      const VerificationMeta('purchaseMode');
  @override
  late final GeneratedColumn<String> purchaseMode = GeneratedColumn<String>(
      'purchase_mode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, nom, actiu, shoppingUnit, purchaseMode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_family';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProductFamilyTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('actiu')) {
      context.handle(
          _actiuMeta, actiu.isAcceptableOrUnknown(data['actiu']!, _actiuMeta));
    }
    if (data.containsKey('shopping_unit')) {
      context.handle(
          _shoppingUnitMeta,
          shoppingUnit.isAcceptableOrUnknown(
              data['shopping_unit']!, _shoppingUnitMeta));
    }
    if (data.containsKey('purchase_mode')) {
      context.handle(
          _purchaseModeMeta,
          purchaseMode.isAcceptableOrUnknown(
              data['purchase_mode']!, _purchaseModeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductFamilyTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductFamilyTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      actiu: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actiu'])!,
      shoppingUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shopping_unit']),
      purchaseMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_mode']),
    );
  }

  @override
  $ProductFamilyTableTable createAlias(String alias) {
    return $ProductFamilyTableTable(attachedDatabase, alias);
  }
}

class ProductFamilyTableData extends DataClass
    implements Insertable<ProductFamilyTableData> {
  final int id;
  final String nom;
  final bool actiu;
  final String? shoppingUnit;
  final String? purchaseMode;
  const ProductFamilyTableData(
      {required this.id,
      required this.nom,
      required this.actiu,
      this.shoppingUnit,
      this.purchaseMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['actiu'] = Variable<bool>(actiu);
    if (!nullToAbsent || shoppingUnit != null) {
      map['shopping_unit'] = Variable<String>(shoppingUnit);
    }
    if (!nullToAbsent || purchaseMode != null) {
      map['purchase_mode'] = Variable<String>(purchaseMode);
    }
    return map;
  }

  ProductFamilyTableCompanion toCompanion(bool nullToAbsent) {
    return ProductFamilyTableCompanion(
      id: Value(id),
      nom: Value(nom),
      actiu: Value(actiu),
      shoppingUnit: shoppingUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingUnit),
      purchaseMode: purchaseMode == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseMode),
    );
  }

  factory ProductFamilyTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductFamilyTableData(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      actiu: serializer.fromJson<bool>(json['actiu']),
      shoppingUnit: serializer.fromJson<String?>(json['shoppingUnit']),
      purchaseMode: serializer.fromJson<String?>(json['purchaseMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'actiu': serializer.toJson<bool>(actiu),
      'shoppingUnit': serializer.toJson<String?>(shoppingUnit),
      'purchaseMode': serializer.toJson<String?>(purchaseMode),
    };
  }

  ProductFamilyTableData copyWith(
          {int? id,
          String? nom,
          bool? actiu,
          Value<String?> shoppingUnit = const Value.absent(),
          Value<String?> purchaseMode = const Value.absent()}) =>
      ProductFamilyTableData(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        actiu: actiu ?? this.actiu,
        shoppingUnit:
            shoppingUnit.present ? shoppingUnit.value : this.shoppingUnit,
        purchaseMode:
            purchaseMode.present ? purchaseMode.value : this.purchaseMode,
      );
  ProductFamilyTableData copyWithCompanion(ProductFamilyTableCompanion data) {
    return ProductFamilyTableData(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      actiu: data.actiu.present ? data.actiu.value : this.actiu,
      shoppingUnit: data.shoppingUnit.present
          ? data.shoppingUnit.value
          : this.shoppingUnit,
      purchaseMode: data.purchaseMode.present
          ? data.purchaseMode.value
          : this.purchaseMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductFamilyTableData(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('actiu: $actiu, ')
          ..write('shoppingUnit: $shoppingUnit, ')
          ..write('purchaseMode: $purchaseMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, actiu, shoppingUnit, purchaseMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductFamilyTableData &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.actiu == this.actiu &&
          other.shoppingUnit == this.shoppingUnit &&
          other.purchaseMode == this.purchaseMode);
}

class ProductFamilyTableCompanion
    extends UpdateCompanion<ProductFamilyTableData> {
  final Value<int> id;
  final Value<String> nom;
  final Value<bool> actiu;
  final Value<String?> shoppingUnit;
  final Value<String?> purchaseMode;
  const ProductFamilyTableCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.actiu = const Value.absent(),
    this.shoppingUnit = const Value.absent(),
    this.purchaseMode = const Value.absent(),
  });
  ProductFamilyTableCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.actiu = const Value.absent(),
    this.shoppingUnit = const Value.absent(),
    this.purchaseMode = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<ProductFamilyTableData> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<bool>? actiu,
    Expression<String>? shoppingUnit,
    Expression<String>? purchaseMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (actiu != null) 'actiu': actiu,
      if (shoppingUnit != null) 'shopping_unit': shoppingUnit,
      if (purchaseMode != null) 'purchase_mode': purchaseMode,
    });
  }

  ProductFamilyTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? nom,
      Value<bool>? actiu,
      Value<String?>? shoppingUnit,
      Value<String?>? purchaseMode}) {
    return ProductFamilyTableCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      actiu: actiu ?? this.actiu,
      shoppingUnit: shoppingUnit ?? this.shoppingUnit,
      purchaseMode: purchaseMode ?? this.purchaseMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (actiu.present) {
      map['actiu'] = Variable<bool>(actiu.value);
    }
    if (shoppingUnit.present) {
      map['shopping_unit'] = Variable<String>(shoppingUnit.value);
    }
    if (purchaseMode.present) {
      map['purchase_mode'] = Variable<String>(purchaseMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductFamilyTableCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('actiu: $actiu, ')
          ..write('shoppingUnit: $shoppingUnit, ')
          ..write('purchaseMode: $purchaseMode')
          ..write(')'))
        .toString();
  }
}

class $ProductItemTableTable extends ProductItemTable
    with TableInfo<$ProductItemTableTable, ProductItemTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actiuMeta = const VerificationMeta('actiu');
  @override
  late final GeneratedColumn<bool> actiu = GeneratedColumn<bool>(
      'actiu', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actiu" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _productFamilyIdMeta =
      const VerificationMeta('productFamilyId');
  @override
  late final GeneratedColumn<int> productFamilyId = GeneratedColumn<int>(
      'product_family_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES product_family (id)'));
  static const VerificationMeta _supermarketIdMeta =
      const VerificationMeta('supermarketId');
  @override
  late final GeneratedColumn<int> supermarketId = GeneratedColumn<int>(
      'supermarket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES supermarket (id)'));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitTypeMeta =
      const VerificationMeta('unitType');
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
      'unit_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pricePerQuantityMeta =
      const VerificationMeta('pricePerQuantity');
  @override
  late final GeneratedColumn<double> pricePerQuantity = GeneratedColumn<double>(
      'price_per_quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _packageQuantityAmountMeta =
      const VerificationMeta('packageQuantityAmount');
  @override
  late final GeneratedColumn<double> packageQuantityAmount =
      GeneratedColumn<double>('package_quantity_amount', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _packageQuantityUnitMeta =
      const VerificationMeta('packageQuantityUnit');
  @override
  late final GeneratedColumn<String> packageQuantityUnit =
      GeneratedColumn<String>('package_quantity_unit', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _normalizedMeasurementUnitMeta =
      const VerificationMeta('normalizedMeasurementUnit');
  @override
  late final GeneratedColumn<String> normalizedMeasurementUnit =
      GeneratedColumn<String>('normalized_measurement_unit', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateAddedMeta =
      const VerificationMeta('dateAdded');
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
      'date_added', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isCurrentPriceMeta =
      const VerificationMeta('isCurrentPrice');
  @override
  late final GeneratedColumn<bool> isCurrentPrice = GeneratedColumn<bool>(
      'is_current_price', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_current_price" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nom,
        actiu,
        productFamilyId,
        supermarketId,
        price,
        quantity,
        unitType,
        pricePerQuantity,
        packageQuantityAmount,
        packageQuantityUnit,
        normalizedMeasurementUnit,
        dateAdded,
        isCurrentPrice,
        barcode
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_item';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProductItemTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('actiu')) {
      context.handle(
          _actiuMeta, actiu.isAcceptableOrUnknown(data['actiu']!, _actiuMeta));
    }
    if (data.containsKey('product_family_id')) {
      context.handle(
          _productFamilyIdMeta,
          productFamilyId.isAcceptableOrUnknown(
              data['product_family_id']!, _productFamilyIdMeta));
    } else if (isInserting) {
      context.missing(_productFamilyIdMeta);
    }
    if (data.containsKey('supermarket_id')) {
      context.handle(
          _supermarketIdMeta,
          supermarketId.isAcceptableOrUnknown(
              data['supermarket_id']!, _supermarketIdMeta));
    } else if (isInserting) {
      context.missing(_supermarketIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(_unitTypeMeta,
          unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta));
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('price_per_quantity')) {
      context.handle(
          _pricePerQuantityMeta,
          pricePerQuantity.isAcceptableOrUnknown(
              data['price_per_quantity']!, _pricePerQuantityMeta));
    } else if (isInserting) {
      context.missing(_pricePerQuantityMeta);
    }
    if (data.containsKey('package_quantity_amount')) {
      context.handle(
          _packageQuantityAmountMeta,
          packageQuantityAmount.isAcceptableOrUnknown(
              data['package_quantity_amount']!, _packageQuantityAmountMeta));
    }
    if (data.containsKey('package_quantity_unit')) {
      context.handle(
          _packageQuantityUnitMeta,
          packageQuantityUnit.isAcceptableOrUnknown(
              data['package_quantity_unit']!, _packageQuantityUnitMeta));
    }
    if (data.containsKey('normalized_measurement_unit')) {
      context.handle(
          _normalizedMeasurementUnitMeta,
          normalizedMeasurementUnit.isAcceptableOrUnknown(
              data['normalized_measurement_unit']!,
              _normalizedMeasurementUnitMeta));
    }
    if (data.containsKey('date_added')) {
      context.handle(_dateAddedMeta,
          dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta));
    }
    if (data.containsKey('is_current_price')) {
      context.handle(
          _isCurrentPriceMeta,
          isCurrentPrice.isAcceptableOrUnknown(
              data['is_current_price']!, _isCurrentPriceMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductItemTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductItemTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      actiu: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actiu'])!,
      productFamilyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_family_id'])!,
      supermarketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supermarket_id'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unitType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_type'])!,
      pricePerQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_per_quantity'])!,
      packageQuantityAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}package_quantity_amount']),
      packageQuantityUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}package_quantity_unit']),
      normalizedMeasurementUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}normalized_measurement_unit']),
      dateAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_added'])!,
      isCurrentPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_current_price'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
    );
  }

  @override
  $ProductItemTableTable createAlias(String alias) {
    return $ProductItemTableTable(attachedDatabase, alias);
  }
}

class ProductItemTableData extends DataClass
    implements Insertable<ProductItemTableData> {
  final int id;
  final String nom;
  final bool actiu;
  final int productFamilyId;
  final int supermarketId;
  final double price;
  final double quantity;
  final String unitType;
  final double pricePerQuantity;
  final double? packageQuantityAmount;
  final String? packageQuantityUnit;
  final String? normalizedMeasurementUnit;
  final DateTime dateAdded;
  final bool isCurrentPrice;
  final String? barcode;
  const ProductItemTableData(
      {required this.id,
      required this.nom,
      required this.actiu,
      required this.productFamilyId,
      required this.supermarketId,
      required this.price,
      required this.quantity,
      required this.unitType,
      required this.pricePerQuantity,
      this.packageQuantityAmount,
      this.packageQuantityUnit,
      this.normalizedMeasurementUnit,
      required this.dateAdded,
      required this.isCurrentPrice,
      this.barcode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['actiu'] = Variable<bool>(actiu);
    map['product_family_id'] = Variable<int>(productFamilyId);
    map['supermarket_id'] = Variable<int>(supermarketId);
    map['price'] = Variable<double>(price);
    map['quantity'] = Variable<double>(quantity);
    map['unit_type'] = Variable<String>(unitType);
    map['price_per_quantity'] = Variable<double>(pricePerQuantity);
    if (!nullToAbsent || packageQuantityAmount != null) {
      map['package_quantity_amount'] = Variable<double>(packageQuantityAmount);
    }
    if (!nullToAbsent || packageQuantityUnit != null) {
      map['package_quantity_unit'] = Variable<String>(packageQuantityUnit);
    }
    if (!nullToAbsent || normalizedMeasurementUnit != null) {
      map['normalized_measurement_unit'] =
          Variable<String>(normalizedMeasurementUnit);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['is_current_price'] = Variable<bool>(isCurrentPrice);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    return map;
  }

  ProductItemTableCompanion toCompanion(bool nullToAbsent) {
    return ProductItemTableCompanion(
      id: Value(id),
      nom: Value(nom),
      actiu: Value(actiu),
      productFamilyId: Value(productFamilyId),
      supermarketId: Value(supermarketId),
      price: Value(price),
      quantity: Value(quantity),
      unitType: Value(unitType),
      pricePerQuantity: Value(pricePerQuantity),
      packageQuantityAmount: packageQuantityAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(packageQuantityAmount),
      packageQuantityUnit: packageQuantityUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(packageQuantityUnit),
      normalizedMeasurementUnit:
          normalizedMeasurementUnit == null && nullToAbsent
              ? const Value.absent()
              : Value(normalizedMeasurementUnit),
      dateAdded: Value(dateAdded),
      isCurrentPrice: Value(isCurrentPrice),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
    );
  }

  factory ProductItemTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductItemTableData(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      actiu: serializer.fromJson<bool>(json['actiu']),
      productFamilyId: serializer.fromJson<int>(json['productFamilyId']),
      supermarketId: serializer.fromJson<int>(json['supermarketId']),
      price: serializer.fromJson<double>(json['price']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitType: serializer.fromJson<String>(json['unitType']),
      pricePerQuantity: serializer.fromJson<double>(json['pricePerQuantity']),
      packageQuantityAmount:
          serializer.fromJson<double?>(json['packageQuantityAmount']),
      packageQuantityUnit:
          serializer.fromJson<String?>(json['packageQuantityUnit']),
      normalizedMeasurementUnit:
          serializer.fromJson<String?>(json['normalizedMeasurementUnit']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      isCurrentPrice: serializer.fromJson<bool>(json['isCurrentPrice']),
      barcode: serializer.fromJson<String?>(json['barcode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'actiu': serializer.toJson<bool>(actiu),
      'productFamilyId': serializer.toJson<int>(productFamilyId),
      'supermarketId': serializer.toJson<int>(supermarketId),
      'price': serializer.toJson<double>(price),
      'quantity': serializer.toJson<double>(quantity),
      'unitType': serializer.toJson<String>(unitType),
      'pricePerQuantity': serializer.toJson<double>(pricePerQuantity),
      'packageQuantityAmount':
          serializer.toJson<double?>(packageQuantityAmount),
      'packageQuantityUnit': serializer.toJson<String?>(packageQuantityUnit),
      'normalizedMeasurementUnit':
          serializer.toJson<String?>(normalizedMeasurementUnit),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'isCurrentPrice': serializer.toJson<bool>(isCurrentPrice),
      'barcode': serializer.toJson<String?>(barcode),
    };
  }

  ProductItemTableData copyWith(
          {int? id,
          String? nom,
          bool? actiu,
          int? productFamilyId,
          int? supermarketId,
          double? price,
          double? quantity,
          String? unitType,
          double? pricePerQuantity,
          Value<double?> packageQuantityAmount = const Value.absent(),
          Value<String?> packageQuantityUnit = const Value.absent(),
          Value<String?> normalizedMeasurementUnit = const Value.absent(),
          DateTime? dateAdded,
          bool? isCurrentPrice,
          Value<String?> barcode = const Value.absent()}) =>
      ProductItemTableData(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        actiu: actiu ?? this.actiu,
        productFamilyId: productFamilyId ?? this.productFamilyId,
        supermarketId: supermarketId ?? this.supermarketId,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        unitType: unitType ?? this.unitType,
        pricePerQuantity: pricePerQuantity ?? this.pricePerQuantity,
        packageQuantityAmount: packageQuantityAmount.present
            ? packageQuantityAmount.value
            : this.packageQuantityAmount,
        packageQuantityUnit: packageQuantityUnit.present
            ? packageQuantityUnit.value
            : this.packageQuantityUnit,
        normalizedMeasurementUnit: normalizedMeasurementUnit.present
            ? normalizedMeasurementUnit.value
            : this.normalizedMeasurementUnit,
        dateAdded: dateAdded ?? this.dateAdded,
        isCurrentPrice: isCurrentPrice ?? this.isCurrentPrice,
        barcode: barcode.present ? barcode.value : this.barcode,
      );
  ProductItemTableData copyWithCompanion(ProductItemTableCompanion data) {
    return ProductItemTableData(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      actiu: data.actiu.present ? data.actiu.value : this.actiu,
      productFamilyId: data.productFamilyId.present
          ? data.productFamilyId.value
          : this.productFamilyId,
      supermarketId: data.supermarketId.present
          ? data.supermarketId.value
          : this.supermarketId,
      price: data.price.present ? data.price.value : this.price,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      pricePerQuantity: data.pricePerQuantity.present
          ? data.pricePerQuantity.value
          : this.pricePerQuantity,
      packageQuantityAmount: data.packageQuantityAmount.present
          ? data.packageQuantityAmount.value
          : this.packageQuantityAmount,
      packageQuantityUnit: data.packageQuantityUnit.present
          ? data.packageQuantityUnit.value
          : this.packageQuantityUnit,
      normalizedMeasurementUnit: data.normalizedMeasurementUnit.present
          ? data.normalizedMeasurementUnit.value
          : this.normalizedMeasurementUnit,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      isCurrentPrice: data.isCurrentPrice.present
          ? data.isCurrentPrice.value
          : this.isCurrentPrice,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductItemTableData(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('actiu: $actiu, ')
          ..write('productFamilyId: $productFamilyId, ')
          ..write('supermarketId: $supermarketId, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('unitType: $unitType, ')
          ..write('pricePerQuantity: $pricePerQuantity, ')
          ..write('packageQuantityAmount: $packageQuantityAmount, ')
          ..write('packageQuantityUnit: $packageQuantityUnit, ')
          ..write('normalizedMeasurementUnit: $normalizedMeasurementUnit, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('isCurrentPrice: $isCurrentPrice, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nom,
      actiu,
      productFamilyId,
      supermarketId,
      price,
      quantity,
      unitType,
      pricePerQuantity,
      packageQuantityAmount,
      packageQuantityUnit,
      normalizedMeasurementUnit,
      dateAdded,
      isCurrentPrice,
      barcode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductItemTableData &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.actiu == this.actiu &&
          other.productFamilyId == this.productFamilyId &&
          other.supermarketId == this.supermarketId &&
          other.price == this.price &&
          other.quantity == this.quantity &&
          other.unitType == this.unitType &&
          other.pricePerQuantity == this.pricePerQuantity &&
          other.packageQuantityAmount == this.packageQuantityAmount &&
          other.packageQuantityUnit == this.packageQuantityUnit &&
          other.normalizedMeasurementUnit == this.normalizedMeasurementUnit &&
          other.dateAdded == this.dateAdded &&
          other.isCurrentPrice == this.isCurrentPrice &&
          other.barcode == this.barcode);
}

class ProductItemTableCompanion extends UpdateCompanion<ProductItemTableData> {
  final Value<int> id;
  final Value<String> nom;
  final Value<bool> actiu;
  final Value<int> productFamilyId;
  final Value<int> supermarketId;
  final Value<double> price;
  final Value<double> quantity;
  final Value<String> unitType;
  final Value<double> pricePerQuantity;
  final Value<double?> packageQuantityAmount;
  final Value<String?> packageQuantityUnit;
  final Value<String?> normalizedMeasurementUnit;
  final Value<DateTime> dateAdded;
  final Value<bool> isCurrentPrice;
  final Value<String?> barcode;
  const ProductItemTableCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.actiu = const Value.absent(),
    this.productFamilyId = const Value.absent(),
    this.supermarketId = const Value.absent(),
    this.price = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitType = const Value.absent(),
    this.pricePerQuantity = const Value.absent(),
    this.packageQuantityAmount = const Value.absent(),
    this.packageQuantityUnit = const Value.absent(),
    this.normalizedMeasurementUnit = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.isCurrentPrice = const Value.absent(),
    this.barcode = const Value.absent(),
  });
  ProductItemTableCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.actiu = const Value.absent(),
    required int productFamilyId,
    required int supermarketId,
    required double price,
    required double quantity,
    required String unitType,
    required double pricePerQuantity,
    this.packageQuantityAmount = const Value.absent(),
    this.packageQuantityUnit = const Value.absent(),
    this.normalizedMeasurementUnit = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.isCurrentPrice = const Value.absent(),
    this.barcode = const Value.absent(),
  })  : nom = Value(nom),
        productFamilyId = Value(productFamilyId),
        supermarketId = Value(supermarketId),
        price = Value(price),
        quantity = Value(quantity),
        unitType = Value(unitType),
        pricePerQuantity = Value(pricePerQuantity);
  static Insertable<ProductItemTableData> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<bool>? actiu,
    Expression<int>? productFamilyId,
    Expression<int>? supermarketId,
    Expression<double>? price,
    Expression<double>? quantity,
    Expression<String>? unitType,
    Expression<double>? pricePerQuantity,
    Expression<double>? packageQuantityAmount,
    Expression<String>? packageQuantityUnit,
    Expression<String>? normalizedMeasurementUnit,
    Expression<DateTime>? dateAdded,
    Expression<bool>? isCurrentPrice,
    Expression<String>? barcode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (actiu != null) 'actiu': actiu,
      if (productFamilyId != null) 'product_family_id': productFamilyId,
      if (supermarketId != null) 'supermarket_id': supermarketId,
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (unitType != null) 'unit_type': unitType,
      if (pricePerQuantity != null) 'price_per_quantity': pricePerQuantity,
      if (packageQuantityAmount != null)
        'package_quantity_amount': packageQuantityAmount,
      if (packageQuantityUnit != null)
        'package_quantity_unit': packageQuantityUnit,
      if (normalizedMeasurementUnit != null)
        'normalized_measurement_unit': normalizedMeasurementUnit,
      if (dateAdded != null) 'date_added': dateAdded,
      if (isCurrentPrice != null) 'is_current_price': isCurrentPrice,
      if (barcode != null) 'barcode': barcode,
    });
  }

  ProductItemTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? nom,
      Value<bool>? actiu,
      Value<int>? productFamilyId,
      Value<int>? supermarketId,
      Value<double>? price,
      Value<double>? quantity,
      Value<String>? unitType,
      Value<double>? pricePerQuantity,
      Value<double?>? packageQuantityAmount,
      Value<String?>? packageQuantityUnit,
      Value<String?>? normalizedMeasurementUnit,
      Value<DateTime>? dateAdded,
      Value<bool>? isCurrentPrice,
      Value<String?>? barcode}) {
    return ProductItemTableCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      actiu: actiu ?? this.actiu,
      productFamilyId: productFamilyId ?? this.productFamilyId,
      supermarketId: supermarketId ?? this.supermarketId,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unitType: unitType ?? this.unitType,
      pricePerQuantity: pricePerQuantity ?? this.pricePerQuantity,
      packageQuantityAmount:
          packageQuantityAmount ?? this.packageQuantityAmount,
      packageQuantityUnit: packageQuantityUnit ?? this.packageQuantityUnit,
      normalizedMeasurementUnit:
          normalizedMeasurementUnit ?? this.normalizedMeasurementUnit,
      dateAdded: dateAdded ?? this.dateAdded,
      isCurrentPrice: isCurrentPrice ?? this.isCurrentPrice,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (actiu.present) {
      map['actiu'] = Variable<bool>(actiu.value);
    }
    if (productFamilyId.present) {
      map['product_family_id'] = Variable<int>(productFamilyId.value);
    }
    if (supermarketId.present) {
      map['supermarket_id'] = Variable<int>(supermarketId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (pricePerQuantity.present) {
      map['price_per_quantity'] = Variable<double>(pricePerQuantity.value);
    }
    if (packageQuantityAmount.present) {
      map['package_quantity_amount'] =
          Variable<double>(packageQuantityAmount.value);
    }
    if (packageQuantityUnit.present) {
      map['package_quantity_unit'] =
          Variable<String>(packageQuantityUnit.value);
    }
    if (normalizedMeasurementUnit.present) {
      map['normalized_measurement_unit'] =
          Variable<String>(normalizedMeasurementUnit.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (isCurrentPrice.present) {
      map['is_current_price'] = Variable<bool>(isCurrentPrice.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductItemTableCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('actiu: $actiu, ')
          ..write('productFamilyId: $productFamilyId, ')
          ..write('supermarketId: $supermarketId, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('unitType: $unitType, ')
          ..write('pricePerQuantity: $pricePerQuantity, ')
          ..write('packageQuantityAmount: $packageQuantityAmount, ')
          ..write('packageQuantityUnit: $packageQuantityUnit, ')
          ..write('normalizedMeasurementUnit: $normalizedMeasurementUnit, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('isCurrentPrice: $isCurrentPrice, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListTableTable extends ShoppingListTable
    with TableInfo<$ShoppingListTableTable, ShoppingListTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productFamilyIdMeta =
      const VerificationMeta('productFamilyId');
  @override
  late final GeneratedColumn<int> productFamilyId = GeneratedColumn<int>(
      'product_family_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES product_family (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productItemIdMeta =
      const VerificationMeta('productItemId');
  @override
  late final GeneratedColumn<int> productItemId = GeneratedColumn<int>(
      'product_item_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES product_item (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, productFamilyId, quantity, productItemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list';
  @override
  VerificationContext validateIntegrity(
      Insertable<ShoppingListTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_family_id')) {
      context.handle(
          _productFamilyIdMeta,
          productFamilyId.isAcceptableOrUnknown(
              data['product_family_id']!, _productFamilyIdMeta));
    } else if (isInserting) {
      context.missing(_productFamilyIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('product_item_id')) {
      context.handle(
          _productItemIdMeta,
          productItemId.isAcceptableOrUnknown(
              data['product_item_id']!, _productItemIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productFamilyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_family_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      productItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_item_id']),
    );
  }

  @override
  $ShoppingListTableTable createAlias(String alias) {
    return $ShoppingListTableTable(attachedDatabase, alias);
  }
}

class ShoppingListTableData extends DataClass
    implements Insertable<ShoppingListTableData> {
  final int id;
  final int productFamilyId;
  final int quantity;
  final int? productItemId;
  const ShoppingListTableData(
      {required this.id,
      required this.productFamilyId,
      required this.quantity,
      this.productItemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_family_id'] = Variable<int>(productFamilyId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || productItemId != null) {
      map['product_item_id'] = Variable<int>(productItemId);
    }
    return map;
  }

  ShoppingListTableCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListTableCompanion(
      id: Value(id),
      productFamilyId: Value(productFamilyId),
      quantity: Value(quantity),
      productItemId: productItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(productItemId),
    );
  }

  factory ShoppingListTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListTableData(
      id: serializer.fromJson<int>(json['id']),
      productFamilyId: serializer.fromJson<int>(json['productFamilyId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      productItemId: serializer.fromJson<int?>(json['productItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productFamilyId': serializer.toJson<int>(productFamilyId),
      'quantity': serializer.toJson<int>(quantity),
      'productItemId': serializer.toJson<int?>(productItemId),
    };
  }

  ShoppingListTableData copyWith(
          {int? id,
          int? productFamilyId,
          int? quantity,
          Value<int?> productItemId = const Value.absent()}) =>
      ShoppingListTableData(
        id: id ?? this.id,
        productFamilyId: productFamilyId ?? this.productFamilyId,
        quantity: quantity ?? this.quantity,
        productItemId:
            productItemId.present ? productItemId.value : this.productItemId,
      );
  ShoppingListTableData copyWithCompanion(ShoppingListTableCompanion data) {
    return ShoppingListTableData(
      id: data.id.present ? data.id.value : this.id,
      productFamilyId: data.productFamilyId.present
          ? data.productFamilyId.value
          : this.productFamilyId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      productItemId: data.productItemId.present
          ? data.productItemId.value
          : this.productItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListTableData(')
          ..write('id: $id, ')
          ..write('productFamilyId: $productFamilyId, ')
          ..write('quantity: $quantity, ')
          ..write('productItemId: $productItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productFamilyId, quantity, productItemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListTableData &&
          other.id == this.id &&
          other.productFamilyId == this.productFamilyId &&
          other.quantity == this.quantity &&
          other.productItemId == this.productItemId);
}

class ShoppingListTableCompanion
    extends UpdateCompanion<ShoppingListTableData> {
  final Value<int> id;
  final Value<int> productFamilyId;
  final Value<int> quantity;
  final Value<int?> productItemId;
  const ShoppingListTableCompanion({
    this.id = const Value.absent(),
    this.productFamilyId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.productItemId = const Value.absent(),
  });
  ShoppingListTableCompanion.insert({
    this.id = const Value.absent(),
    required int productFamilyId,
    required int quantity,
    this.productItemId = const Value.absent(),
  })  : productFamilyId = Value(productFamilyId),
        quantity = Value(quantity);
  static Insertable<ShoppingListTableData> custom({
    Expression<int>? id,
    Expression<int>? productFamilyId,
    Expression<int>? quantity,
    Expression<int>? productItemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productFamilyId != null) 'product_family_id': productFamilyId,
      if (quantity != null) 'quantity': quantity,
      if (productItemId != null) 'product_item_id': productItemId,
    });
  }

  ShoppingListTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? productFamilyId,
      Value<int>? quantity,
      Value<int?>? productItemId}) {
    return ShoppingListTableCompanion(
      id: id ?? this.id,
      productFamilyId: productFamilyId ?? this.productFamilyId,
      quantity: quantity ?? this.quantity,
      productItemId: productItemId ?? this.productItemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productFamilyId.present) {
      map['product_family_id'] = Variable<int>(productFamilyId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (productItemId.present) {
      map['product_item_id'] = Variable<int>(productItemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListTableCompanion(')
          ..write('id: $id, ')
          ..write('productFamilyId: $productFamilyId, ')
          ..write('quantity: $quantity, ')
          ..write('productItemId: $productItemId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDriftDatabase extends GeneratedDatabase {
  _$AppDriftDatabase(QueryExecutor e) : super(e);
  $AppDriftDatabaseManager get managers => $AppDriftDatabaseManager(this);
  late final $SupermarketTableTable supermarketTable =
      $SupermarketTableTable(this);
  late final $ProductFamilyTableTable productFamilyTable =
      $ProductFamilyTableTable(this);
  late final $ProductItemTableTable productItemTable =
      $ProductItemTableTable(this);
  late final $ShoppingListTableTable shoppingListTable =
      $ShoppingListTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        supermarketTable,
        productFamilyTable,
        productItemTable,
        shoppingListTable
      ];
}

typedef $$SupermarketTableTableCreateCompanionBuilder
    = SupermarketTableCompanion Function({
  Value<int> id,
  required String nom,
  Value<String?> adreca,
  Value<bool> actiu,
});
typedef $$SupermarketTableTableUpdateCompanionBuilder
    = SupermarketTableCompanion Function({
  Value<int> id,
  Value<String> nom,
  Value<String?> adreca,
  Value<bool> actiu,
});

final class $$SupermarketTableTableReferences extends BaseReferences<
    _$AppDriftDatabase, $SupermarketTableTable, SupermarketTableData> {
  $$SupermarketTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductItemTableTable, List<ProductItemTableData>>
      _productItemTableRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.productItemTable,
              aliasName: $_aliasNameGenerator(
                  db.supermarketTable.id, db.productItemTable.supermarketId));

  $$ProductItemTableTableProcessedTableManager get productItemTableRefs {
    final manager = $$ProductItemTableTableTableManager(
            $_db, $_db.productItemTable)
        .filter((f) => f.supermarketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_productItemTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SupermarketTableTableFilterComposer
    extends Composer<_$AppDriftDatabase, $SupermarketTableTable> {
  $$SupermarketTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adreca => $composableBuilder(
      column: $table.adreca, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actiu => $composableBuilder(
      column: $table.actiu, builder: (column) => ColumnFilters(column));

  Expression<bool> productItemTableRefs(
      Expression<bool> Function($$ProductItemTableTableFilterComposer f) f) {
    final $$ProductItemTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.supermarketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableFilterComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SupermarketTableTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $SupermarketTableTable> {
  $$SupermarketTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adreca => $composableBuilder(
      column: $table.adreca, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actiu => $composableBuilder(
      column: $table.actiu, builder: (column) => ColumnOrderings(column));
}

class $$SupermarketTableTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $SupermarketTableTable> {
  $$SupermarketTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get adreca =>
      $composableBuilder(column: $table.adreca, builder: (column) => column);

  GeneratedColumn<bool> get actiu =>
      $composableBuilder(column: $table.actiu, builder: (column) => column);

  Expression<T> productItemTableRefs<T extends Object>(
      Expression<T> Function($$ProductItemTableTableAnnotationComposer a) f) {
    final $$ProductItemTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.supermarketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableAnnotationComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SupermarketTableTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $SupermarketTableTable,
    SupermarketTableData,
    $$SupermarketTableTableFilterComposer,
    $$SupermarketTableTableOrderingComposer,
    $$SupermarketTableTableAnnotationComposer,
    $$SupermarketTableTableCreateCompanionBuilder,
    $$SupermarketTableTableUpdateCompanionBuilder,
    (SupermarketTableData, $$SupermarketTableTableReferences),
    SupermarketTableData,
    PrefetchHooks Function({bool productItemTableRefs})> {
  $$SupermarketTableTableTableManager(
      _$AppDriftDatabase db, $SupermarketTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupermarketTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupermarketTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupermarketTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> adreca = const Value.absent(),
            Value<bool> actiu = const Value.absent(),
          }) =>
              SupermarketTableCompanion(
            id: id,
            nom: nom,
            adreca: adreca,
            actiu: actiu,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nom,
            Value<String?> adreca = const Value.absent(),
            Value<bool> actiu = const Value.absent(),
          }) =>
              SupermarketTableCompanion.insert(
            id: id,
            nom: nom,
            adreca: adreca,
            actiu: actiu,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SupermarketTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productItemTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productItemTableRefs) db.productItemTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productItemTableRefs)
                    await $_getPrefetchedData<SupermarketTableData,
                            $SupermarketTableTable, ProductItemTableData>(
                        currentTable: table,
                        referencedTable: $$SupermarketTableTableReferences
                            ._productItemTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SupermarketTableTableReferences(db, table, p0)
                                .productItemTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.supermarketId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SupermarketTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $SupermarketTableTable,
    SupermarketTableData,
    $$SupermarketTableTableFilterComposer,
    $$SupermarketTableTableOrderingComposer,
    $$SupermarketTableTableAnnotationComposer,
    $$SupermarketTableTableCreateCompanionBuilder,
    $$SupermarketTableTableUpdateCompanionBuilder,
    (SupermarketTableData, $$SupermarketTableTableReferences),
    SupermarketTableData,
    PrefetchHooks Function({bool productItemTableRefs})>;
typedef $$ProductFamilyTableTableCreateCompanionBuilder
    = ProductFamilyTableCompanion Function({
  Value<int> id,
  required String nom,
  Value<bool> actiu,
  Value<String?> shoppingUnit,
  Value<String?> purchaseMode,
});
typedef $$ProductFamilyTableTableUpdateCompanionBuilder
    = ProductFamilyTableCompanion Function({
  Value<int> id,
  Value<String> nom,
  Value<bool> actiu,
  Value<String?> shoppingUnit,
  Value<String?> purchaseMode,
});

final class $$ProductFamilyTableTableReferences extends BaseReferences<
    _$AppDriftDatabase, $ProductFamilyTableTable, ProductFamilyTableData> {
  $$ProductFamilyTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductItemTableTable, List<ProductItemTableData>>
      _productItemTableRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.productItemTable,
              aliasName: $_aliasNameGenerator(db.productFamilyTable.id,
                  db.productItemTable.productFamilyId));

  $$ProductItemTableTableProcessedTableManager get productItemTableRefs {
    final manager =
        $$ProductItemTableTableTableManager($_db, $_db.productItemTable).filter(
            (f) => f.productFamilyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_productItemTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ShoppingListTableTable,
      List<ShoppingListTableData>> _shoppingListTableRefsTable(
          _$AppDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.shoppingListTable,
          aliasName: $_aliasNameGenerator(
              db.productFamilyTable.id, db.shoppingListTable.productFamilyId));

  $$ShoppingListTableTableProcessedTableManager get shoppingListTableRefs {
    final manager = $$ShoppingListTableTableTableManager(
            $_db, $_db.shoppingListTable)
        .filter(
            (f) => f.productFamilyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_shoppingListTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductFamilyTableTableFilterComposer
    extends Composer<_$AppDriftDatabase, $ProductFamilyTableTable> {
  $$ProductFamilyTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actiu => $composableBuilder(
      column: $table.actiu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shoppingUnit => $composableBuilder(
      column: $table.shoppingUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseMode => $composableBuilder(
      column: $table.purchaseMode, builder: (column) => ColumnFilters(column));

  Expression<bool> productItemTableRefs(
      Expression<bool> Function($$ProductItemTableTableFilterComposer f) f) {
    final $$ProductItemTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.productFamilyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableFilterComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> shoppingListTableRefs(
      Expression<bool> Function($$ShoppingListTableTableFilterComposer f) f) {
    final $$ShoppingListTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shoppingListTable,
        getReferencedColumn: (t) => t.productFamilyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShoppingListTableTableFilterComposer(
              $db: $db,
              $table: $db.shoppingListTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductFamilyTableTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $ProductFamilyTableTable> {
  $$ProductFamilyTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actiu => $composableBuilder(
      column: $table.actiu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shoppingUnit => $composableBuilder(
      column: $table.shoppingUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseMode => $composableBuilder(
      column: $table.purchaseMode,
      builder: (column) => ColumnOrderings(column));
}

class $$ProductFamilyTableTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $ProductFamilyTableTable> {
  $$ProductFamilyTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<bool> get actiu =>
      $composableBuilder(column: $table.actiu, builder: (column) => column);

  GeneratedColumn<String> get shoppingUnit => $composableBuilder(
      column: $table.shoppingUnit, builder: (column) => column);

  GeneratedColumn<String> get purchaseMode => $composableBuilder(
      column: $table.purchaseMode, builder: (column) => column);

  Expression<T> productItemTableRefs<T extends Object>(
      Expression<T> Function($$ProductItemTableTableAnnotationComposer a) f) {
    final $$ProductItemTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.productFamilyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableAnnotationComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> shoppingListTableRefs<T extends Object>(
      Expression<T> Function($$ShoppingListTableTableAnnotationComposer a) f) {
    final $$ShoppingListTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.shoppingListTable,
            getReferencedColumn: (t) => t.productFamilyId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ShoppingListTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.shoppingListTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductFamilyTableTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $ProductFamilyTableTable,
    ProductFamilyTableData,
    $$ProductFamilyTableTableFilterComposer,
    $$ProductFamilyTableTableOrderingComposer,
    $$ProductFamilyTableTableAnnotationComposer,
    $$ProductFamilyTableTableCreateCompanionBuilder,
    $$ProductFamilyTableTableUpdateCompanionBuilder,
    (ProductFamilyTableData, $$ProductFamilyTableTableReferences),
    ProductFamilyTableData,
    PrefetchHooks Function(
        {bool productItemTableRefs, bool shoppingListTableRefs})> {
  $$ProductFamilyTableTableTableManager(
      _$AppDriftDatabase db, $ProductFamilyTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductFamilyTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductFamilyTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductFamilyTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<bool> actiu = const Value.absent(),
            Value<String?> shoppingUnit = const Value.absent(),
            Value<String?> purchaseMode = const Value.absent(),
          }) =>
              ProductFamilyTableCompanion(
            id: id,
            nom: nom,
            actiu: actiu,
            shoppingUnit: shoppingUnit,
            purchaseMode: purchaseMode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nom,
            Value<bool> actiu = const Value.absent(),
            Value<String?> shoppingUnit = const Value.absent(),
            Value<String?> purchaseMode = const Value.absent(),
          }) =>
              ProductFamilyTableCompanion.insert(
            id: id,
            nom: nom,
            actiu: actiu,
            shoppingUnit: shoppingUnit,
            purchaseMode: purchaseMode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductFamilyTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {productItemTableRefs = false, shoppingListTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productItemTableRefs) db.productItemTable,
                if (shoppingListTableRefs) db.shoppingListTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productItemTableRefs)
                    await $_getPrefetchedData<ProductFamilyTableData,
                            $ProductFamilyTableTable, ProductItemTableData>(
                        currentTable: table,
                        referencedTable: $$ProductFamilyTableTableReferences
                            ._productItemTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductFamilyTableTableReferences(db, table, p0)
                                .productItemTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productFamilyId == item.id),
                        typedResults: items),
                  if (shoppingListTableRefs)
                    await $_getPrefetchedData<ProductFamilyTableData,
                            $ProductFamilyTableTable, ShoppingListTableData>(
                        currentTable: table,
                        referencedTable: $$ProductFamilyTableTableReferences
                            ._shoppingListTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductFamilyTableTableReferences(db, table, p0)
                                .shoppingListTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productFamilyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductFamilyTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $ProductFamilyTableTable,
    ProductFamilyTableData,
    $$ProductFamilyTableTableFilterComposer,
    $$ProductFamilyTableTableOrderingComposer,
    $$ProductFamilyTableTableAnnotationComposer,
    $$ProductFamilyTableTableCreateCompanionBuilder,
    $$ProductFamilyTableTableUpdateCompanionBuilder,
    (ProductFamilyTableData, $$ProductFamilyTableTableReferences),
    ProductFamilyTableData,
    PrefetchHooks Function(
        {bool productItemTableRefs, bool shoppingListTableRefs})>;
typedef $$ProductItemTableTableCreateCompanionBuilder
    = ProductItemTableCompanion Function({
  Value<int> id,
  required String nom,
  Value<bool> actiu,
  required int productFamilyId,
  required int supermarketId,
  required double price,
  required double quantity,
  required String unitType,
  required double pricePerQuantity,
  Value<double?> packageQuantityAmount,
  Value<String?> packageQuantityUnit,
  Value<String?> normalizedMeasurementUnit,
  Value<DateTime> dateAdded,
  Value<bool> isCurrentPrice,
  Value<String?> barcode,
});
typedef $$ProductItemTableTableUpdateCompanionBuilder
    = ProductItemTableCompanion Function({
  Value<int> id,
  Value<String> nom,
  Value<bool> actiu,
  Value<int> productFamilyId,
  Value<int> supermarketId,
  Value<double> price,
  Value<double> quantity,
  Value<String> unitType,
  Value<double> pricePerQuantity,
  Value<double?> packageQuantityAmount,
  Value<String?> packageQuantityUnit,
  Value<String?> normalizedMeasurementUnit,
  Value<DateTime> dateAdded,
  Value<bool> isCurrentPrice,
  Value<String?> barcode,
});

final class $$ProductItemTableTableReferences extends BaseReferences<
    _$AppDriftDatabase, $ProductItemTableTable, ProductItemTableData> {
  $$ProductItemTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductFamilyTableTable _productFamilyIdTable(
          _$AppDriftDatabase db) =>
      db.productFamilyTable.createAlias($_aliasNameGenerator(
          db.productItemTable.productFamilyId, db.productFamilyTable.id));

  $$ProductFamilyTableTableProcessedTableManager get productFamilyId {
    final $_column = $_itemColumn<int>('product_family_id')!;

    final manager =
        $$ProductFamilyTableTableTableManager($_db, $_db.productFamilyTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productFamilyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SupermarketTableTable _supermarketIdTable(_$AppDriftDatabase db) =>
      db.supermarketTable.createAlias($_aliasNameGenerator(
          db.productItemTable.supermarketId, db.supermarketTable.id));

  $$SupermarketTableTableProcessedTableManager get supermarketId {
    final $_column = $_itemColumn<int>('supermarket_id')!;

    final manager =
        $$SupermarketTableTableTableManager($_db, $_db.supermarketTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supermarketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ShoppingListTableTable,
      List<ShoppingListTableData>> _shoppingListTableRefsTable(
          _$AppDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.shoppingListTable,
          aliasName: $_aliasNameGenerator(
              db.productItemTable.id, db.shoppingListTable.productItemId));

  $$ShoppingListTableTableProcessedTableManager get shoppingListTableRefs {
    final manager = $$ShoppingListTableTableTableManager(
            $_db, $_db.shoppingListTable)
        .filter((f) => f.productItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_shoppingListTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductItemTableTableFilterComposer
    extends Composer<_$AppDriftDatabase, $ProductItemTableTable> {
  $$ProductItemTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actiu => $composableBuilder(
      column: $table.actiu, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitType => $composableBuilder(
      column: $table.unitType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerQuantity => $composableBuilder(
      column: $table.pricePerQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get packageQuantityAmount => $composableBuilder(
      column: $table.packageQuantityAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageQuantityUnit => $composableBuilder(
      column: $table.packageQuantityUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedMeasurementUnit => $composableBuilder(
      column: $table.normalizedMeasurementUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCurrentPrice => $composableBuilder(
      column: $table.isCurrentPrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  $$ProductFamilyTableTableFilterComposer get productFamilyId {
    final $$ProductFamilyTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productFamilyId,
        referencedTable: $db.productFamilyTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductFamilyTableTableFilterComposer(
              $db: $db,
              $table: $db.productFamilyTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SupermarketTableTableFilterComposer get supermarketId {
    final $$SupermarketTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supermarketId,
        referencedTable: $db.supermarketTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupermarketTableTableFilterComposer(
              $db: $db,
              $table: $db.supermarketTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> shoppingListTableRefs(
      Expression<bool> Function($$ShoppingListTableTableFilterComposer f) f) {
    final $$ShoppingListTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shoppingListTable,
        getReferencedColumn: (t) => t.productItemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShoppingListTableTableFilterComposer(
              $db: $db,
              $table: $db.shoppingListTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductItemTableTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $ProductItemTableTable> {
  $$ProductItemTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actiu => $composableBuilder(
      column: $table.actiu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitType => $composableBuilder(
      column: $table.unitType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerQuantity => $composableBuilder(
      column: $table.pricePerQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get packageQuantityAmount => $composableBuilder(
      column: $table.packageQuantityAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageQuantityUnit => $composableBuilder(
      column: $table.packageQuantityUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedMeasurementUnit => $composableBuilder(
      column: $table.normalizedMeasurementUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCurrentPrice => $composableBuilder(
      column: $table.isCurrentPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  $$ProductFamilyTableTableOrderingComposer get productFamilyId {
    final $$ProductFamilyTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productFamilyId,
        referencedTable: $db.productFamilyTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductFamilyTableTableOrderingComposer(
              $db: $db,
              $table: $db.productFamilyTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SupermarketTableTableOrderingComposer get supermarketId {
    final $$SupermarketTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supermarketId,
        referencedTable: $db.supermarketTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupermarketTableTableOrderingComposer(
              $db: $db,
              $table: $db.supermarketTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductItemTableTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $ProductItemTableTable> {
  $$ProductItemTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<bool> get actiu =>
      $composableBuilder(column: $table.actiu, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<double> get pricePerQuantity => $composableBuilder(
      column: $table.pricePerQuantity, builder: (column) => column);

  GeneratedColumn<double> get packageQuantityAmount => $composableBuilder(
      column: $table.packageQuantityAmount, builder: (column) => column);

  GeneratedColumn<String> get packageQuantityUnit => $composableBuilder(
      column: $table.packageQuantityUnit, builder: (column) => column);

  GeneratedColumn<String> get normalizedMeasurementUnit => $composableBuilder(
      column: $table.normalizedMeasurementUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<bool> get isCurrentPrice => $composableBuilder(
      column: $table.isCurrentPrice, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  $$ProductFamilyTableTableAnnotationComposer get productFamilyId {
    final $$ProductFamilyTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.productFamilyId,
            referencedTable: $db.productFamilyTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ProductFamilyTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.productFamilyTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$SupermarketTableTableAnnotationComposer get supermarketId {
    final $$SupermarketTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supermarketId,
        referencedTable: $db.supermarketTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupermarketTableTableAnnotationComposer(
              $db: $db,
              $table: $db.supermarketTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> shoppingListTableRefs<T extends Object>(
      Expression<T> Function($$ShoppingListTableTableAnnotationComposer a) f) {
    final $$ShoppingListTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.shoppingListTable,
            getReferencedColumn: (t) => t.productItemId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ShoppingListTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.shoppingListTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductItemTableTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $ProductItemTableTable,
    ProductItemTableData,
    $$ProductItemTableTableFilterComposer,
    $$ProductItemTableTableOrderingComposer,
    $$ProductItemTableTableAnnotationComposer,
    $$ProductItemTableTableCreateCompanionBuilder,
    $$ProductItemTableTableUpdateCompanionBuilder,
    (ProductItemTableData, $$ProductItemTableTableReferences),
    ProductItemTableData,
    PrefetchHooks Function(
        {bool productFamilyId,
        bool supermarketId,
        bool shoppingListTableRefs})> {
  $$ProductItemTableTableTableManager(
      _$AppDriftDatabase db, $ProductItemTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductItemTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductItemTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductItemTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<bool> actiu = const Value.absent(),
            Value<int> productFamilyId = const Value.absent(),
            Value<int> supermarketId = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unitType = const Value.absent(),
            Value<double> pricePerQuantity = const Value.absent(),
            Value<double?> packageQuantityAmount = const Value.absent(),
            Value<String?> packageQuantityUnit = const Value.absent(),
            Value<String?> normalizedMeasurementUnit = const Value.absent(),
            Value<DateTime> dateAdded = const Value.absent(),
            Value<bool> isCurrentPrice = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
          }) =>
              ProductItemTableCompanion(
            id: id,
            nom: nom,
            actiu: actiu,
            productFamilyId: productFamilyId,
            supermarketId: supermarketId,
            price: price,
            quantity: quantity,
            unitType: unitType,
            pricePerQuantity: pricePerQuantity,
            packageQuantityAmount: packageQuantityAmount,
            packageQuantityUnit: packageQuantityUnit,
            normalizedMeasurementUnit: normalizedMeasurementUnit,
            dateAdded: dateAdded,
            isCurrentPrice: isCurrentPrice,
            barcode: barcode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nom,
            Value<bool> actiu = const Value.absent(),
            required int productFamilyId,
            required int supermarketId,
            required double price,
            required double quantity,
            required String unitType,
            required double pricePerQuantity,
            Value<double?> packageQuantityAmount = const Value.absent(),
            Value<String?> packageQuantityUnit = const Value.absent(),
            Value<String?> normalizedMeasurementUnit = const Value.absent(),
            Value<DateTime> dateAdded = const Value.absent(),
            Value<bool> isCurrentPrice = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
          }) =>
              ProductItemTableCompanion.insert(
            id: id,
            nom: nom,
            actiu: actiu,
            productFamilyId: productFamilyId,
            supermarketId: supermarketId,
            price: price,
            quantity: quantity,
            unitType: unitType,
            pricePerQuantity: pricePerQuantity,
            packageQuantityAmount: packageQuantityAmount,
            packageQuantityUnit: packageQuantityUnit,
            normalizedMeasurementUnit: normalizedMeasurementUnit,
            dateAdded: dateAdded,
            isCurrentPrice: isCurrentPrice,
            barcode: barcode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductItemTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {productFamilyId = false,
              supermarketId = false,
              shoppingListTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shoppingListTableRefs) db.shoppingListTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productFamilyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productFamilyId,
                    referencedTable: $$ProductItemTableTableReferences
                        ._productFamilyIdTable(db),
                    referencedColumn: $$ProductItemTableTableReferences
                        ._productFamilyIdTable(db)
                        .id,
                  ) as T;
                }
                if (supermarketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.supermarketId,
                    referencedTable: $$ProductItemTableTableReferences
                        ._supermarketIdTable(db),
                    referencedColumn: $$ProductItemTableTableReferences
                        ._supermarketIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shoppingListTableRefs)
                    await $_getPrefetchedData<ProductItemTableData,
                            $ProductItemTableTable, ShoppingListTableData>(
                        currentTable: table,
                        referencedTable: $$ProductItemTableTableReferences
                            ._shoppingListTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductItemTableTableReferences(db, table, p0)
                                .shoppingListTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productItemId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductItemTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $ProductItemTableTable,
    ProductItemTableData,
    $$ProductItemTableTableFilterComposer,
    $$ProductItemTableTableOrderingComposer,
    $$ProductItemTableTableAnnotationComposer,
    $$ProductItemTableTableCreateCompanionBuilder,
    $$ProductItemTableTableUpdateCompanionBuilder,
    (ProductItemTableData, $$ProductItemTableTableReferences),
    ProductItemTableData,
    PrefetchHooks Function(
        {bool productFamilyId,
        bool supermarketId,
        bool shoppingListTableRefs})>;
typedef $$ShoppingListTableTableCreateCompanionBuilder
    = ShoppingListTableCompanion Function({
  Value<int> id,
  required int productFamilyId,
  required int quantity,
  Value<int?> productItemId,
});
typedef $$ShoppingListTableTableUpdateCompanionBuilder
    = ShoppingListTableCompanion Function({
  Value<int> id,
  Value<int> productFamilyId,
  Value<int> quantity,
  Value<int?> productItemId,
});

final class $$ShoppingListTableTableReferences extends BaseReferences<
    _$AppDriftDatabase, $ShoppingListTableTable, ShoppingListTableData> {
  $$ShoppingListTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductFamilyTableTable _productFamilyIdTable(
          _$AppDriftDatabase db) =>
      db.productFamilyTable.createAlias($_aliasNameGenerator(
          db.shoppingListTable.productFamilyId, db.productFamilyTable.id));

  $$ProductFamilyTableTableProcessedTableManager get productFamilyId {
    final $_column = $_itemColumn<int>('product_family_id')!;

    final manager =
        $$ProductFamilyTableTableTableManager($_db, $_db.productFamilyTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productFamilyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductItemTableTable _productItemIdTable(_$AppDriftDatabase db) =>
      db.productItemTable.createAlias($_aliasNameGenerator(
          db.shoppingListTable.productItemId, db.productItemTable.id));

  $$ProductItemTableTableProcessedTableManager? get productItemId {
    final $_column = $_itemColumn<int>('product_item_id');
    if ($_column == null) return null;
    final manager =
        $$ProductItemTableTableTableManager($_db, $_db.productItemTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ShoppingListTableTableFilterComposer
    extends Composer<_$AppDriftDatabase, $ShoppingListTableTable> {
  $$ShoppingListTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  $$ProductFamilyTableTableFilterComposer get productFamilyId {
    final $$ProductFamilyTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productFamilyId,
        referencedTable: $db.productFamilyTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductFamilyTableTableFilterComposer(
              $db: $db,
              $table: $db.productFamilyTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductItemTableTableFilterComposer get productItemId {
    final $$ProductItemTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productItemId,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableFilterComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShoppingListTableTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $ShoppingListTableTable> {
  $$ShoppingListTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  $$ProductFamilyTableTableOrderingComposer get productFamilyId {
    final $$ProductFamilyTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productFamilyId,
        referencedTable: $db.productFamilyTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductFamilyTableTableOrderingComposer(
              $db: $db,
              $table: $db.productFamilyTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductItemTableTableOrderingComposer get productItemId {
    final $$ProductItemTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productItemId,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableOrderingComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShoppingListTableTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $ShoppingListTableTable> {
  $$ShoppingListTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$ProductFamilyTableTableAnnotationComposer get productFamilyId {
    final $$ProductFamilyTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.productFamilyId,
            referencedTable: $db.productFamilyTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ProductFamilyTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.productFamilyTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ProductItemTableTableAnnotationComposer get productItemId {
    final $$ProductItemTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productItemId,
        referencedTable: $db.productItemTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductItemTableTableAnnotationComposer(
              $db: $db,
              $table: $db.productItemTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShoppingListTableTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $ShoppingListTableTable,
    ShoppingListTableData,
    $$ShoppingListTableTableFilterComposer,
    $$ShoppingListTableTableOrderingComposer,
    $$ShoppingListTableTableAnnotationComposer,
    $$ShoppingListTableTableCreateCompanionBuilder,
    $$ShoppingListTableTableUpdateCompanionBuilder,
    (ShoppingListTableData, $$ShoppingListTableTableReferences),
    ShoppingListTableData,
    PrefetchHooks Function({bool productFamilyId, bool productItemId})> {
  $$ShoppingListTableTableTableManager(
      _$AppDriftDatabase db, $ShoppingListTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productFamilyId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int?> productItemId = const Value.absent(),
          }) =>
              ShoppingListTableCompanion(
            id: id,
            productFamilyId: productFamilyId,
            quantity: quantity,
            productItemId: productItemId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productFamilyId,
            required int quantity,
            Value<int?> productItemId = const Value.absent(),
          }) =>
              ShoppingListTableCompanion.insert(
            id: id,
            productFamilyId: productFamilyId,
            quantity: quantity,
            productItemId: productItemId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ShoppingListTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {productFamilyId = false, productItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productFamilyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productFamilyId,
                    referencedTable: $$ShoppingListTableTableReferences
                        ._productFamilyIdTable(db),
                    referencedColumn: $$ShoppingListTableTableReferences
                        ._productFamilyIdTable(db)
                        .id,
                  ) as T;
                }
                if (productItemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productItemId,
                    referencedTable: $$ShoppingListTableTableReferences
                        ._productItemIdTable(db),
                    referencedColumn: $$ShoppingListTableTableReferences
                        ._productItemIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ShoppingListTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $ShoppingListTableTable,
    ShoppingListTableData,
    $$ShoppingListTableTableFilterComposer,
    $$ShoppingListTableTableOrderingComposer,
    $$ShoppingListTableTableAnnotationComposer,
    $$ShoppingListTableTableCreateCompanionBuilder,
    $$ShoppingListTableTableUpdateCompanionBuilder,
    (ShoppingListTableData, $$ShoppingListTableTableReferences),
    ShoppingListTableData,
    PrefetchHooks Function({bool productFamilyId, bool productItemId})>;

class $AppDriftDatabaseManager {
  final _$AppDriftDatabase _db;
  $AppDriftDatabaseManager(this._db);
  $$SupermarketTableTableTableManager get supermarketTable =>
      $$SupermarketTableTableTableManager(_db, _db.supermarketTable);
  $$ProductFamilyTableTableTableManager get productFamilyTable =>
      $$ProductFamilyTableTableTableManager(_db, _db.productFamilyTable);
  $$ProductItemTableTableTableManager get productItemTable =>
      $$ProductItemTableTableTableManager(_db, _db.productItemTable);
  $$ShoppingListTableTableTableManager get shoppingListTable =>
      $$ShoppingListTableTableTableManager(_db, _db.shoppingListTable);
}
