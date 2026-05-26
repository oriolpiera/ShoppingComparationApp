import 'package:isar/isar.dart';

part 'supermarket.g.dart';

@collection
class Supermarket {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  String? address;
}
