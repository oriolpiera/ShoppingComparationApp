import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String barcode;

  @Index(caseSensitive: false)
  late String name;

  String? brand;
}
