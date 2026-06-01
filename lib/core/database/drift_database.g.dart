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
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _supermarketIdMeta =
      const VerificationMeta('supermarketId');
  @override
  late final GeneratedColumn<int> supermarketId = GeneratedColumn<int>(
      'supermarket_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  static const VerificationMeta _externalObservationIdMeta =
      const VerificationMeta('externalObservationId');
  @override
  late final GeneratedColumn<int> externalObservationId = GeneratedColumn<int>(
      'external_observation_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
        barcode,
        externalObservationId
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
    if (data.containsKey('external_observation_id')) {
      context.handle(
          _externalObservationIdMeta,
          externalObservationId.isAcceptableOrUnknown(
              data['external_observation_id']!, _externalObservationIdMeta));
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
      externalObservationId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}external_observation_id']),
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
  final int? externalObservationId;
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
      this.barcode,
      this.externalObservationId});
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
    if (!nullToAbsent || externalObservationId != null) {
      map['external_observation_id'] = Variable<int>(externalObservationId);
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
      externalObservationId: externalObservationId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalObservationId),
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
      externalObservationId:
          serializer.fromJson<int?>(json['externalObservationId']),
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
      'externalObservationId': serializer.toJson<int?>(externalObservationId),
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
          Value<String?> barcode = const Value.absent(),
          Value<int?> externalObservationId = const Value.absent()}) =>
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
        externalObservationId: externalObservationId.present
            ? externalObservationId.value
            : this.externalObservationId,
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
      externalObservationId: data.externalObservationId.present
          ? data.externalObservationId.value
          : this.externalObservationId,
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
          ..write('barcode: $barcode, ')
          ..write('externalObservationId: $externalObservationId')
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
      barcode,
      externalObservationId);
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
          other.barcode == this.barcode &&
          other.externalObservationId == this.externalObservationId);
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
  final Value<int?> externalObservationId;
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
    this.externalObservationId = const Value.absent(),
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
    this.externalObservationId = const Value.absent(),
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
    Expression<int>? externalObservationId,
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
      if (externalObservationId != null)
        'external_observation_id': externalObservationId,
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
      Value<String?>? barcode,
      Value<int?>? externalObservationId}) {
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
      externalObservationId:
          externalObservationId ?? this.externalObservationId,
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
    if (externalObservationId.present) {
      map['external_observation_id'] =
          Variable<int>(externalObservationId.value);
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
          ..write('barcode: $barcode, ')
          ..write('externalObservationId: $externalObservationId')
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
      type: DriftSqlType.int, requiredDuringInsert: true);
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
      type: DriftSqlType.int, requiredDuringInsert: false);
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

class $ExternalStoreMappingTableTable extends ExternalStoreMappingTable
    with
        TableInfo<$ExternalStoreMappingTableTable,
            ExternalStoreMappingTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExternalStoreMappingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _externalStoreIdMeta =
      const VerificationMeta('externalStoreId');
  @override
  late final GeneratedColumn<String> externalStoreId = GeneratedColumn<String>(
      'external_store_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _externalStoreNameMeta =
      const VerificationMeta('externalStoreName');
  @override
  late final GeneratedColumn<String> externalStoreName =
      GeneratedColumn<String>('external_store_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supermarketIdMeta =
      const VerificationMeta('supermarketId');
  @override
  late final GeneratedColumn<int> supermarketId = GeneratedColumn<int>(
      'supermarket_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, externalStoreId, externalStoreName, supermarketId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'external_store_mapping';
  @override
  VerificationContext validateIntegrity(
      Insertable<ExternalStoreMappingTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_store_id')) {
      context.handle(
          _externalStoreIdMeta,
          externalStoreId.isAcceptableOrUnknown(
              data['external_store_id']!, _externalStoreIdMeta));
    } else if (isInserting) {
      context.missing(_externalStoreIdMeta);
    }
    if (data.containsKey('external_store_name')) {
      context.handle(
          _externalStoreNameMeta,
          externalStoreName.isAcceptableOrUnknown(
              data['external_store_name']!, _externalStoreNameMeta));
    } else if (isInserting) {
      context.missing(_externalStoreNameMeta);
    }
    if (data.containsKey('supermarket_id')) {
      context.handle(
          _supermarketIdMeta,
          supermarketId.isAcceptableOrUnknown(
              data['supermarket_id']!, _supermarketIdMeta));
    } else if (isInserting) {
      context.missing(_supermarketIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {externalStoreId},
      ];
  @override
  ExternalStoreMappingTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExternalStoreMappingTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      externalStoreId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_store_id'])!,
      externalStoreName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_store_name'])!,
      supermarketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supermarket_id'])!,
    );
  }

  @override
  $ExternalStoreMappingTableTable createAlias(String alias) {
    return $ExternalStoreMappingTableTable(attachedDatabase, alias);
  }
}

class ExternalStoreMappingTableData extends DataClass
    implements Insertable<ExternalStoreMappingTableData> {
  final int id;
  final String externalStoreId;
  final String externalStoreName;
  final int supermarketId;
  const ExternalStoreMappingTableData(
      {required this.id,
      required this.externalStoreId,
      required this.externalStoreName,
      required this.supermarketId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['external_store_id'] = Variable<String>(externalStoreId);
    map['external_store_name'] = Variable<String>(externalStoreName);
    map['supermarket_id'] = Variable<int>(supermarketId);
    return map;
  }

  ExternalStoreMappingTableCompanion toCompanion(bool nullToAbsent) {
    return ExternalStoreMappingTableCompanion(
      id: Value(id),
      externalStoreId: Value(externalStoreId),
      externalStoreName: Value(externalStoreName),
      supermarketId: Value(supermarketId),
    );
  }

  factory ExternalStoreMappingTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExternalStoreMappingTableData(
      id: serializer.fromJson<int>(json['id']),
      externalStoreId: serializer.fromJson<String>(json['externalStoreId']),
      externalStoreName: serializer.fromJson<String>(json['externalStoreName']),
      supermarketId: serializer.fromJson<int>(json['supermarketId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalStoreId': serializer.toJson<String>(externalStoreId),
      'externalStoreName': serializer.toJson<String>(externalStoreName),
      'supermarketId': serializer.toJson<int>(supermarketId),
    };
  }

  ExternalStoreMappingTableData copyWith(
          {int? id,
          String? externalStoreId,
          String? externalStoreName,
          int? supermarketId}) =>
      ExternalStoreMappingTableData(
        id: id ?? this.id,
        externalStoreId: externalStoreId ?? this.externalStoreId,
        externalStoreName: externalStoreName ?? this.externalStoreName,
        supermarketId: supermarketId ?? this.supermarketId,
      );
  ExternalStoreMappingTableData copyWithCompanion(
      ExternalStoreMappingTableCompanion data) {
    return ExternalStoreMappingTableData(
      id: data.id.present ? data.id.value : this.id,
      externalStoreId: data.externalStoreId.present
          ? data.externalStoreId.value
          : this.externalStoreId,
      externalStoreName: data.externalStoreName.present
          ? data.externalStoreName.value
          : this.externalStoreName,
      supermarketId: data.supermarketId.present
          ? data.supermarketId.value
          : this.supermarketId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExternalStoreMappingTableData(')
          ..write('id: $id, ')
          ..write('externalStoreId: $externalStoreId, ')
          ..write('externalStoreName: $externalStoreName, ')
          ..write('supermarketId: $supermarketId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, externalStoreId, externalStoreName, supermarketId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExternalStoreMappingTableData &&
          other.id == this.id &&
          other.externalStoreId == this.externalStoreId &&
          other.externalStoreName == this.externalStoreName &&
          other.supermarketId == this.supermarketId);
}

class ExternalStoreMappingTableCompanion
    extends UpdateCompanion<ExternalStoreMappingTableData> {
  final Value<int> id;
  final Value<String> externalStoreId;
  final Value<String> externalStoreName;
  final Value<int> supermarketId;
  const ExternalStoreMappingTableCompanion({
    this.id = const Value.absent(),
    this.externalStoreId = const Value.absent(),
    this.externalStoreName = const Value.absent(),
    this.supermarketId = const Value.absent(),
  });
  ExternalStoreMappingTableCompanion.insert({
    this.id = const Value.absent(),
    required String externalStoreId,
    required String externalStoreName,
    required int supermarketId,
  })  : externalStoreId = Value(externalStoreId),
        externalStoreName = Value(externalStoreName),
        supermarketId = Value(supermarketId);
  static Insertable<ExternalStoreMappingTableData> custom({
    Expression<int>? id,
    Expression<String>? externalStoreId,
    Expression<String>? externalStoreName,
    Expression<int>? supermarketId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalStoreId != null) 'external_store_id': externalStoreId,
      if (externalStoreName != null) 'external_store_name': externalStoreName,
      if (supermarketId != null) 'supermarket_id': supermarketId,
    });
  }

  ExternalStoreMappingTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? externalStoreId,
      Value<String>? externalStoreName,
      Value<int>? supermarketId}) {
    return ExternalStoreMappingTableCompanion(
      id: id ?? this.id,
      externalStoreId: externalStoreId ?? this.externalStoreId,
      externalStoreName: externalStoreName ?? this.externalStoreName,
      supermarketId: supermarketId ?? this.supermarketId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (externalStoreId.present) {
      map['external_store_id'] = Variable<String>(externalStoreId.value);
    }
    if (externalStoreName.present) {
      map['external_store_name'] = Variable<String>(externalStoreName.value);
    }
    if (supermarketId.present) {
      map['supermarket_id'] = Variable<int>(supermarketId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExternalStoreMappingTableCompanion(')
          ..write('id: $id, ')
          ..write('externalStoreId: $externalStoreId, ')
          ..write('externalStoreName: $externalStoreName, ')
          ..write('supermarketId: $supermarketId')
          ..write(')'))
        .toString();
  }
}

class $ExternalPriceObservationTableTable extends ExternalPriceObservationTable
    with
        TableInfo<$ExternalPriceObservationTableTable,
            ExternalPriceObservationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExternalPriceObservationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _openPricesIdMeta =
      const VerificationMeta('openPricesId');
  @override
  late final GeneratedColumn<String> openPricesId = GeneratedColumn<String>(
      'open_prices_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _familyNameMeta =
      const VerificationMeta('familyName');
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
      'family_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _externalStoreIdMeta =
      const VerificationMeta('externalStoreId');
  @override
  late final GeneratedColumn<String> externalStoreId = GeneratedColumn<String>(
      'external_store_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _externalStoreNameMeta =
      const VerificationMeta('externalStoreName');
  @override
  late final GeneratedColumn<String> externalStoreName =
      GeneratedColumn<String>('external_store_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _observedAtMeta =
      const VerificationMeta('observedAt');
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
      'observed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _reviewStatusMeta =
      const VerificationMeta('reviewStatus');
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
      'review_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unreviewed'));
  static const VerificationMeta _localProductItemIdMeta =
      const VerificationMeta('localProductItemId');
  @override
  late final GeneratedColumn<int> localProductItemId = GeneratedColumn<int>(
      'local_product_item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        openPricesId,
        productName,
        familyName,
        externalStoreId,
        externalStoreName,
        price,
        quantity,
        unitType,
        pricePerQuantity,
        observedAt,
        reviewStatus,
        localProductItemId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'external_price_observation';
  @override
  VerificationContext validateIntegrity(
      Insertable<ExternalPriceObservationTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('open_prices_id')) {
      context.handle(
          _openPricesIdMeta,
          openPricesId.isAcceptableOrUnknown(
              data['open_prices_id']!, _openPricesIdMeta));
    } else if (isInserting) {
      context.missing(_openPricesIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('family_name')) {
      context.handle(
          _familyNameMeta,
          familyName.isAcceptableOrUnknown(
              data['family_name']!, _familyNameMeta));
    } else if (isInserting) {
      context.missing(_familyNameMeta);
    }
    if (data.containsKey('external_store_id')) {
      context.handle(
          _externalStoreIdMeta,
          externalStoreId.isAcceptableOrUnknown(
              data['external_store_id']!, _externalStoreIdMeta));
    } else if (isInserting) {
      context.missing(_externalStoreIdMeta);
    }
    if (data.containsKey('external_store_name')) {
      context.handle(
          _externalStoreNameMeta,
          externalStoreName.isAcceptableOrUnknown(
              data['external_store_name']!, _externalStoreNameMeta));
    } else if (isInserting) {
      context.missing(_externalStoreNameMeta);
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
    if (data.containsKey('observed_at')) {
      context.handle(
          _observedAtMeta,
          observedAt.isAcceptableOrUnknown(
              data['observed_at']!, _observedAtMeta));
    }
    if (data.containsKey('review_status')) {
      context.handle(
          _reviewStatusMeta,
          reviewStatus.isAcceptableOrUnknown(
              data['review_status']!, _reviewStatusMeta));
    }
    if (data.containsKey('local_product_item_id')) {
      context.handle(
          _localProductItemIdMeta,
          localProductItemId.isAcceptableOrUnknown(
              data['local_product_item_id']!, _localProductItemIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {openPricesId},
      ];
  @override
  ExternalPriceObservationTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExternalPriceObservationTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      openPricesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}open_prices_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      familyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family_name'])!,
      externalStoreId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_store_id'])!,
      externalStoreName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_store_name'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unitType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_type'])!,
      pricePerQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_per_quantity'])!,
      observedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}observed_at'])!,
      reviewStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review_status'])!,
      localProductItemId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}local_product_item_id']),
    );
  }

  @override
  $ExternalPriceObservationTableTable createAlias(String alias) {
    return $ExternalPriceObservationTableTable(attachedDatabase, alias);
  }
}

class ExternalPriceObservationTableData extends DataClass
    implements Insertable<ExternalPriceObservationTableData> {
  final int id;
  final String openPricesId;
  final String productName;
  final String familyName;
  final String externalStoreId;
  final String externalStoreName;
  final double price;
  final double quantity;
  final String unitType;
  final double pricePerQuantity;
  final DateTime observedAt;
  final String reviewStatus;
  final int? localProductItemId;
  const ExternalPriceObservationTableData(
      {required this.id,
      required this.openPricesId,
      required this.productName,
      required this.familyName,
      required this.externalStoreId,
      required this.externalStoreName,
      required this.price,
      required this.quantity,
      required this.unitType,
      required this.pricePerQuantity,
      required this.observedAt,
      required this.reviewStatus,
      this.localProductItemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['open_prices_id'] = Variable<String>(openPricesId);
    map['product_name'] = Variable<String>(productName);
    map['family_name'] = Variable<String>(familyName);
    map['external_store_id'] = Variable<String>(externalStoreId);
    map['external_store_name'] = Variable<String>(externalStoreName);
    map['price'] = Variable<double>(price);
    map['quantity'] = Variable<double>(quantity);
    map['unit_type'] = Variable<String>(unitType);
    map['price_per_quantity'] = Variable<double>(pricePerQuantity);
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || localProductItemId != null) {
      map['local_product_item_id'] = Variable<int>(localProductItemId);
    }
    return map;
  }

  ExternalPriceObservationTableCompanion toCompanion(bool nullToAbsent) {
    return ExternalPriceObservationTableCompanion(
      id: Value(id),
      openPricesId: Value(openPricesId),
      productName: Value(productName),
      familyName: Value(familyName),
      externalStoreId: Value(externalStoreId),
      externalStoreName: Value(externalStoreName),
      price: Value(price),
      quantity: Value(quantity),
      unitType: Value(unitType),
      pricePerQuantity: Value(pricePerQuantity),
      observedAt: Value(observedAt),
      reviewStatus: Value(reviewStatus),
      localProductItemId: localProductItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(localProductItemId),
    );
  }

  factory ExternalPriceObservationTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExternalPriceObservationTableData(
      id: serializer.fromJson<int>(json['id']),
      openPricesId: serializer.fromJson<String>(json['openPricesId']),
      productName: serializer.fromJson<String>(json['productName']),
      familyName: serializer.fromJson<String>(json['familyName']),
      externalStoreId: serializer.fromJson<String>(json['externalStoreId']),
      externalStoreName: serializer.fromJson<String>(json['externalStoreName']),
      price: serializer.fromJson<double>(json['price']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitType: serializer.fromJson<String>(json['unitType']),
      pricePerQuantity: serializer.fromJson<double>(json['pricePerQuantity']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      localProductItemId: serializer.fromJson<int?>(json['localProductItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'openPricesId': serializer.toJson<String>(openPricesId),
      'productName': serializer.toJson<String>(productName),
      'familyName': serializer.toJson<String>(familyName),
      'externalStoreId': serializer.toJson<String>(externalStoreId),
      'externalStoreName': serializer.toJson<String>(externalStoreName),
      'price': serializer.toJson<double>(price),
      'quantity': serializer.toJson<double>(quantity),
      'unitType': serializer.toJson<String>(unitType),
      'pricePerQuantity': serializer.toJson<double>(pricePerQuantity),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'localProductItemId': serializer.toJson<int?>(localProductItemId),
    };
  }

  ExternalPriceObservationTableData copyWith(
          {int? id,
          String? openPricesId,
          String? productName,
          String? familyName,
          String? externalStoreId,
          String? externalStoreName,
          double? price,
          double? quantity,
          String? unitType,
          double? pricePerQuantity,
          DateTime? observedAt,
          String? reviewStatus,
          Value<int?> localProductItemId = const Value.absent()}) =>
      ExternalPriceObservationTableData(
        id: id ?? this.id,
        openPricesId: openPricesId ?? this.openPricesId,
        productName: productName ?? this.productName,
        familyName: familyName ?? this.familyName,
        externalStoreId: externalStoreId ?? this.externalStoreId,
        externalStoreName: externalStoreName ?? this.externalStoreName,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        unitType: unitType ?? this.unitType,
        pricePerQuantity: pricePerQuantity ?? this.pricePerQuantity,
        observedAt: observedAt ?? this.observedAt,
        reviewStatus: reviewStatus ?? this.reviewStatus,
        localProductItemId: localProductItemId.present
            ? localProductItemId.value
            : this.localProductItemId,
      );
  ExternalPriceObservationTableData copyWithCompanion(
      ExternalPriceObservationTableCompanion data) {
    return ExternalPriceObservationTableData(
      id: data.id.present ? data.id.value : this.id,
      openPricesId: data.openPricesId.present
          ? data.openPricesId.value
          : this.openPricesId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      familyName:
          data.familyName.present ? data.familyName.value : this.familyName,
      externalStoreId: data.externalStoreId.present
          ? data.externalStoreId.value
          : this.externalStoreId,
      externalStoreName: data.externalStoreName.present
          ? data.externalStoreName.value
          : this.externalStoreName,
      price: data.price.present ? data.price.value : this.price,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      pricePerQuantity: data.pricePerQuantity.present
          ? data.pricePerQuantity.value
          : this.pricePerQuantity,
      observedAt:
          data.observedAt.present ? data.observedAt.value : this.observedAt,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      localProductItemId: data.localProductItemId.present
          ? data.localProductItemId.value
          : this.localProductItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExternalPriceObservationTableData(')
          ..write('id: $id, ')
          ..write('openPricesId: $openPricesId, ')
          ..write('productName: $productName, ')
          ..write('familyName: $familyName, ')
          ..write('externalStoreId: $externalStoreId, ')
          ..write('externalStoreName: $externalStoreName, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('unitType: $unitType, ')
          ..write('pricePerQuantity: $pricePerQuantity, ')
          ..write('observedAt: $observedAt, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('localProductItemId: $localProductItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      openPricesId,
      productName,
      familyName,
      externalStoreId,
      externalStoreName,
      price,
      quantity,
      unitType,
      pricePerQuantity,
      observedAt,
      reviewStatus,
      localProductItemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExternalPriceObservationTableData &&
          other.id == this.id &&
          other.openPricesId == this.openPricesId &&
          other.productName == this.productName &&
          other.familyName == this.familyName &&
          other.externalStoreId == this.externalStoreId &&
          other.externalStoreName == this.externalStoreName &&
          other.price == this.price &&
          other.quantity == this.quantity &&
          other.unitType == this.unitType &&
          other.pricePerQuantity == this.pricePerQuantity &&
          other.observedAt == this.observedAt &&
          other.reviewStatus == this.reviewStatus &&
          other.localProductItemId == this.localProductItemId);
}

class ExternalPriceObservationTableCompanion
    extends UpdateCompanion<ExternalPriceObservationTableData> {
  final Value<int> id;
  final Value<String> openPricesId;
  final Value<String> productName;
  final Value<String> familyName;
  final Value<String> externalStoreId;
  final Value<String> externalStoreName;
  final Value<double> price;
  final Value<double> quantity;
  final Value<String> unitType;
  final Value<double> pricePerQuantity;
  final Value<DateTime> observedAt;
  final Value<String> reviewStatus;
  final Value<int?> localProductItemId;
  const ExternalPriceObservationTableCompanion({
    this.id = const Value.absent(),
    this.openPricesId = const Value.absent(),
    this.productName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.externalStoreId = const Value.absent(),
    this.externalStoreName = const Value.absent(),
    this.price = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitType = const Value.absent(),
    this.pricePerQuantity = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.localProductItemId = const Value.absent(),
  });
  ExternalPriceObservationTableCompanion.insert({
    this.id = const Value.absent(),
    required String openPricesId,
    required String productName,
    required String familyName,
    required String externalStoreId,
    required String externalStoreName,
    required double price,
    required double quantity,
    required String unitType,
    required double pricePerQuantity,
    this.observedAt = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.localProductItemId = const Value.absent(),
  })  : openPricesId = Value(openPricesId),
        productName = Value(productName),
        familyName = Value(familyName),
        externalStoreId = Value(externalStoreId),
        externalStoreName = Value(externalStoreName),
        price = Value(price),
        quantity = Value(quantity),
        unitType = Value(unitType),
        pricePerQuantity = Value(pricePerQuantity);
  static Insertable<ExternalPriceObservationTableData> custom({
    Expression<int>? id,
    Expression<String>? openPricesId,
    Expression<String>? productName,
    Expression<String>? familyName,
    Expression<String>? externalStoreId,
    Expression<String>? externalStoreName,
    Expression<double>? price,
    Expression<double>? quantity,
    Expression<String>? unitType,
    Expression<double>? pricePerQuantity,
    Expression<DateTime>? observedAt,
    Expression<String>? reviewStatus,
    Expression<int>? localProductItemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openPricesId != null) 'open_prices_id': openPricesId,
      if (productName != null) 'product_name': productName,
      if (familyName != null) 'family_name': familyName,
      if (externalStoreId != null) 'external_store_id': externalStoreId,
      if (externalStoreName != null) 'external_store_name': externalStoreName,
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (unitType != null) 'unit_type': unitType,
      if (pricePerQuantity != null) 'price_per_quantity': pricePerQuantity,
      if (observedAt != null) 'observed_at': observedAt,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (localProductItemId != null)
        'local_product_item_id': localProductItemId,
    });
  }

  ExternalPriceObservationTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? openPricesId,
      Value<String>? productName,
      Value<String>? familyName,
      Value<String>? externalStoreId,
      Value<String>? externalStoreName,
      Value<double>? price,
      Value<double>? quantity,
      Value<String>? unitType,
      Value<double>? pricePerQuantity,
      Value<DateTime>? observedAt,
      Value<String>? reviewStatus,
      Value<int?>? localProductItemId}) {
    return ExternalPriceObservationTableCompanion(
      id: id ?? this.id,
      openPricesId: openPricesId ?? this.openPricesId,
      productName: productName ?? this.productName,
      familyName: familyName ?? this.familyName,
      externalStoreId: externalStoreId ?? this.externalStoreId,
      externalStoreName: externalStoreName ?? this.externalStoreName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unitType: unitType ?? this.unitType,
      pricePerQuantity: pricePerQuantity ?? this.pricePerQuantity,
      observedAt: observedAt ?? this.observedAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      localProductItemId: localProductItemId ?? this.localProductItemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (openPricesId.present) {
      map['open_prices_id'] = Variable<String>(openPricesId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (externalStoreId.present) {
      map['external_store_id'] = Variable<String>(externalStoreId.value);
    }
    if (externalStoreName.present) {
      map['external_store_name'] = Variable<String>(externalStoreName.value);
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
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (localProductItemId.present) {
      map['local_product_item_id'] = Variable<int>(localProductItemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExternalPriceObservationTableCompanion(')
          ..write('id: $id, ')
          ..write('openPricesId: $openPricesId, ')
          ..write('productName: $productName, ')
          ..write('familyName: $familyName, ')
          ..write('externalStoreId: $externalStoreId, ')
          ..write('externalStoreName: $externalStoreName, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('unitType: $unitType, ')
          ..write('pricePerQuantity: $pricePerQuantity, ')
          ..write('observedAt: $observedAt, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('localProductItemId: $localProductItemId')
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
  late final $ExternalStoreMappingTableTable externalStoreMappingTable =
      $ExternalStoreMappingTableTable(this);
  late final $ExternalPriceObservationTableTable externalPriceObservationTable =
      $ExternalPriceObservationTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        supermarketTable,
        productFamilyTable,
        productItemTable,
        shoppingListTable,
        externalStoreMappingTable,
        externalPriceObservationTable
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
    (
      SupermarketTableData,
      BaseReferences<_$AppDriftDatabase, $SupermarketTableTable,
          SupermarketTableData>
    ),
    SupermarketTableData,
    PrefetchHooks Function()> {
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (
      SupermarketTableData,
      BaseReferences<_$AppDriftDatabase, $SupermarketTableTable,
          SupermarketTableData>
    ),
    SupermarketTableData,
    PrefetchHooks Function()>;
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
    (
      ProductFamilyTableData,
      BaseReferences<_$AppDriftDatabase, $ProductFamilyTableTable,
          ProductFamilyTableData>
    ),
    ProductFamilyTableData,
    PrefetchHooks Function()> {
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (
      ProductFamilyTableData,
      BaseReferences<_$AppDriftDatabase, $ProductFamilyTableTable,
          ProductFamilyTableData>
    ),
    ProductFamilyTableData,
    PrefetchHooks Function()>;
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
  Value<int?> externalObservationId,
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
  Value<int?> externalObservationId,
});

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

  ColumnFilters<int> get productFamilyId => $composableBuilder(
      column: $table.productFamilyId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get supermarketId => $composableBuilder(
      column: $table.supermarketId, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<int> get externalObservationId => $composableBuilder(
      column: $table.externalObservationId,
      builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<int> get productFamilyId => $composableBuilder(
      column: $table.productFamilyId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get supermarketId => $composableBuilder(
      column: $table.supermarketId,
      builder: (column) => ColumnOrderings(column));

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

  ColumnOrderings<int> get externalObservationId => $composableBuilder(
      column: $table.externalObservationId,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get productFamilyId => $composableBuilder(
      column: $table.productFamilyId, builder: (column) => column);

  GeneratedColumn<int> get supermarketId => $composableBuilder(
      column: $table.supermarketId, builder: (column) => column);

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

  GeneratedColumn<int> get externalObservationId => $composableBuilder(
      column: $table.externalObservationId, builder: (column) => column);
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
    (
      ProductItemTableData,
      BaseReferences<_$AppDriftDatabase, $ProductItemTableTable,
          ProductItemTableData>
    ),
    ProductItemTableData,
    PrefetchHooks Function()> {
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
            Value<int?> externalObservationId = const Value.absent(),
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
            externalObservationId: externalObservationId,
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
            Value<int?> externalObservationId = const Value.absent(),
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
            externalObservationId: externalObservationId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (
      ProductItemTableData,
      BaseReferences<_$AppDriftDatabase, $ProductItemTableTable,
          ProductItemTableData>
    ),
    ProductItemTableData,
    PrefetchHooks Function()>;
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

  ColumnFilters<int> get productFamilyId => $composableBuilder(
      column: $table.productFamilyId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productItemId => $composableBuilder(
      column: $table.productItemId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<int> get productFamilyId => $composableBuilder(
      column: $table.productFamilyId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productItemId => $composableBuilder(
      column: $table.productItemId,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get productFamilyId => $composableBuilder(
      column: $table.productFamilyId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get productItemId => $composableBuilder(
      column: $table.productItemId, builder: (column) => column);
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
    (
      ShoppingListTableData,
      BaseReferences<_$AppDriftDatabase, $ShoppingListTableTable,
          ShoppingListTableData>
    ),
    ShoppingListTableData,
    PrefetchHooks Function()> {
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (
      ShoppingListTableData,
      BaseReferences<_$AppDriftDatabase, $ShoppingListTableTable,
          ShoppingListTableData>
    ),
    ShoppingListTableData,
    PrefetchHooks Function()>;
typedef $$ExternalStoreMappingTableTableCreateCompanionBuilder
    = ExternalStoreMappingTableCompanion Function({
  Value<int> id,
  required String externalStoreId,
  required String externalStoreName,
  required int supermarketId,
});
typedef $$ExternalStoreMappingTableTableUpdateCompanionBuilder
    = ExternalStoreMappingTableCompanion Function({
  Value<int> id,
  Value<String> externalStoreId,
  Value<String> externalStoreName,
  Value<int> supermarketId,
});

class $$ExternalStoreMappingTableTableFilterComposer
    extends Composer<_$AppDriftDatabase, $ExternalStoreMappingTableTable> {
  $$ExternalStoreMappingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalStoreId => $composableBuilder(
      column: $table.externalStoreId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalStoreName => $composableBuilder(
      column: $table.externalStoreName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get supermarketId => $composableBuilder(
      column: $table.supermarketId, builder: (column) => ColumnFilters(column));
}

class $$ExternalStoreMappingTableTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $ExternalStoreMappingTableTable> {
  $$ExternalStoreMappingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalStoreId => $composableBuilder(
      column: $table.externalStoreId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalStoreName => $composableBuilder(
      column: $table.externalStoreName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get supermarketId => $composableBuilder(
      column: $table.supermarketId,
      builder: (column) => ColumnOrderings(column));
}

class $$ExternalStoreMappingTableTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $ExternalStoreMappingTableTable> {
  $$ExternalStoreMappingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalStoreId => $composableBuilder(
      column: $table.externalStoreId, builder: (column) => column);

  GeneratedColumn<String> get externalStoreName => $composableBuilder(
      column: $table.externalStoreName, builder: (column) => column);

  GeneratedColumn<int> get supermarketId => $composableBuilder(
      column: $table.supermarketId, builder: (column) => column);
}

class $$ExternalStoreMappingTableTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $ExternalStoreMappingTableTable,
    ExternalStoreMappingTableData,
    $$ExternalStoreMappingTableTableFilterComposer,
    $$ExternalStoreMappingTableTableOrderingComposer,
    $$ExternalStoreMappingTableTableAnnotationComposer,
    $$ExternalStoreMappingTableTableCreateCompanionBuilder,
    $$ExternalStoreMappingTableTableUpdateCompanionBuilder,
    (
      ExternalStoreMappingTableData,
      BaseReferences<_$AppDriftDatabase, $ExternalStoreMappingTableTable,
          ExternalStoreMappingTableData>
    ),
    ExternalStoreMappingTableData,
    PrefetchHooks Function()> {
  $$ExternalStoreMappingTableTableTableManager(
      _$AppDriftDatabase db, $ExternalStoreMappingTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExternalStoreMappingTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ExternalStoreMappingTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExternalStoreMappingTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> externalStoreId = const Value.absent(),
            Value<String> externalStoreName = const Value.absent(),
            Value<int> supermarketId = const Value.absent(),
          }) =>
              ExternalStoreMappingTableCompanion(
            id: id,
            externalStoreId: externalStoreId,
            externalStoreName: externalStoreName,
            supermarketId: supermarketId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String externalStoreId,
            required String externalStoreName,
            required int supermarketId,
          }) =>
              ExternalStoreMappingTableCompanion.insert(
            id: id,
            externalStoreId: externalStoreId,
            externalStoreName: externalStoreName,
            supermarketId: supermarketId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExternalStoreMappingTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDriftDatabase,
        $ExternalStoreMappingTableTable,
        ExternalStoreMappingTableData,
        $$ExternalStoreMappingTableTableFilterComposer,
        $$ExternalStoreMappingTableTableOrderingComposer,
        $$ExternalStoreMappingTableTableAnnotationComposer,
        $$ExternalStoreMappingTableTableCreateCompanionBuilder,
        $$ExternalStoreMappingTableTableUpdateCompanionBuilder,
        (
          ExternalStoreMappingTableData,
          BaseReferences<_$AppDriftDatabase, $ExternalStoreMappingTableTable,
              ExternalStoreMappingTableData>
        ),
        ExternalStoreMappingTableData,
        PrefetchHooks Function()>;
typedef $$ExternalPriceObservationTableTableCreateCompanionBuilder
    = ExternalPriceObservationTableCompanion Function({
  Value<int> id,
  required String openPricesId,
  required String productName,
  required String familyName,
  required String externalStoreId,
  required String externalStoreName,
  required double price,
  required double quantity,
  required String unitType,
  required double pricePerQuantity,
  Value<DateTime> observedAt,
  Value<String> reviewStatus,
  Value<int?> localProductItemId,
});
typedef $$ExternalPriceObservationTableTableUpdateCompanionBuilder
    = ExternalPriceObservationTableCompanion Function({
  Value<int> id,
  Value<String> openPricesId,
  Value<String> productName,
  Value<String> familyName,
  Value<String> externalStoreId,
  Value<String> externalStoreName,
  Value<double> price,
  Value<double> quantity,
  Value<String> unitType,
  Value<double> pricePerQuantity,
  Value<DateTime> observedAt,
  Value<String> reviewStatus,
  Value<int?> localProductItemId,
});

class $$ExternalPriceObservationTableTableFilterComposer
    extends Composer<_$AppDriftDatabase, $ExternalPriceObservationTableTable> {
  $$ExternalPriceObservationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openPricesId => $composableBuilder(
      column: $table.openPricesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalStoreId => $composableBuilder(
      column: $table.externalStoreId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalStoreName => $composableBuilder(
      column: $table.externalStoreName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitType => $composableBuilder(
      column: $table.unitType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerQuantity => $composableBuilder(
      column: $table.pricePerQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewStatus => $composableBuilder(
      column: $table.reviewStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localProductItemId => $composableBuilder(
      column: $table.localProductItemId,
      builder: (column) => ColumnFilters(column));
}

class $$ExternalPriceObservationTableTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $ExternalPriceObservationTableTable> {
  $$ExternalPriceObservationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openPricesId => $composableBuilder(
      column: $table.openPricesId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalStoreId => $composableBuilder(
      column: $table.externalStoreId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalStoreName => $composableBuilder(
      column: $table.externalStoreName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitType => $composableBuilder(
      column: $table.unitType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerQuantity => $composableBuilder(
      column: $table.pricePerQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
      column: $table.reviewStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localProductItemId => $composableBuilder(
      column: $table.localProductItemId,
      builder: (column) => ColumnOrderings(column));
}

class $$ExternalPriceObservationTableTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $ExternalPriceObservationTableTable> {
  $$ExternalPriceObservationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get openPricesId => $composableBuilder(
      column: $table.openPricesId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => column);

  GeneratedColumn<String> get externalStoreId => $composableBuilder(
      column: $table.externalStoreId, builder: (column) => column);

  GeneratedColumn<String> get externalStoreName => $composableBuilder(
      column: $table.externalStoreName, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<double> get pricePerQuantity => $composableBuilder(
      column: $table.pricePerQuantity, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
      column: $table.reviewStatus, builder: (column) => column);

  GeneratedColumn<int> get localProductItemId => $composableBuilder(
      column: $table.localProductItemId, builder: (column) => column);
}

class $$ExternalPriceObservationTableTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $ExternalPriceObservationTableTable,
    ExternalPriceObservationTableData,
    $$ExternalPriceObservationTableTableFilterComposer,
    $$ExternalPriceObservationTableTableOrderingComposer,
    $$ExternalPriceObservationTableTableAnnotationComposer,
    $$ExternalPriceObservationTableTableCreateCompanionBuilder,
    $$ExternalPriceObservationTableTableUpdateCompanionBuilder,
    (
      ExternalPriceObservationTableData,
      BaseReferences<_$AppDriftDatabase, $ExternalPriceObservationTableTable,
          ExternalPriceObservationTableData>
    ),
    ExternalPriceObservationTableData,
    PrefetchHooks Function()> {
  $$ExternalPriceObservationTableTableTableManager(
      _$AppDriftDatabase db, $ExternalPriceObservationTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExternalPriceObservationTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ExternalPriceObservationTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExternalPriceObservationTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> openPricesId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String> familyName = const Value.absent(),
            Value<String> externalStoreId = const Value.absent(),
            Value<String> externalStoreName = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unitType = const Value.absent(),
            Value<double> pricePerQuantity = const Value.absent(),
            Value<DateTime> observedAt = const Value.absent(),
            Value<String> reviewStatus = const Value.absent(),
            Value<int?> localProductItemId = const Value.absent(),
          }) =>
              ExternalPriceObservationTableCompanion(
            id: id,
            openPricesId: openPricesId,
            productName: productName,
            familyName: familyName,
            externalStoreId: externalStoreId,
            externalStoreName: externalStoreName,
            price: price,
            quantity: quantity,
            unitType: unitType,
            pricePerQuantity: pricePerQuantity,
            observedAt: observedAt,
            reviewStatus: reviewStatus,
            localProductItemId: localProductItemId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String openPricesId,
            required String productName,
            required String familyName,
            required String externalStoreId,
            required String externalStoreName,
            required double price,
            required double quantity,
            required String unitType,
            required double pricePerQuantity,
            Value<DateTime> observedAt = const Value.absent(),
            Value<String> reviewStatus = const Value.absent(),
            Value<int?> localProductItemId = const Value.absent(),
          }) =>
              ExternalPriceObservationTableCompanion.insert(
            id: id,
            openPricesId: openPricesId,
            productName: productName,
            familyName: familyName,
            externalStoreId: externalStoreId,
            externalStoreName: externalStoreName,
            price: price,
            quantity: quantity,
            unitType: unitType,
            pricePerQuantity: pricePerQuantity,
            observedAt: observedAt,
            reviewStatus: reviewStatus,
            localProductItemId: localProductItemId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExternalPriceObservationTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDriftDatabase,
        $ExternalPriceObservationTableTable,
        ExternalPriceObservationTableData,
        $$ExternalPriceObservationTableTableFilterComposer,
        $$ExternalPriceObservationTableTableOrderingComposer,
        $$ExternalPriceObservationTableTableAnnotationComposer,
        $$ExternalPriceObservationTableTableCreateCompanionBuilder,
        $$ExternalPriceObservationTableTableUpdateCompanionBuilder,
        (
          ExternalPriceObservationTableData,
          BaseReferences<
              _$AppDriftDatabase,
              $ExternalPriceObservationTableTable,
              ExternalPriceObservationTableData>
        ),
        ExternalPriceObservationTableData,
        PrefetchHooks Function()>;

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
  $$ExternalStoreMappingTableTableTableManager get externalStoreMappingTable =>
      $$ExternalStoreMappingTableTableTableManager(
          _db, _db.externalStoreMappingTable);
  $$ExternalPriceObservationTableTableTableManager
      get externalPriceObservationTable =>
          $$ExternalPriceObservationTableTableTableManager(
              _db, _db.externalPriceObservationTable);
}
