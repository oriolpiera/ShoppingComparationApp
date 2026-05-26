import 'package:isar/isar.dart';

part 'price_entry.g.dart';

@collection
class PriceEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late Id productId;

  @Index()
  late Id supermarketId;

  late double price;
  late DateTime capturedAt;
}
