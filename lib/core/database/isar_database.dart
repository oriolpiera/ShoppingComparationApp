import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/prices/data/models/price_entry.dart';
import '../../features/products/data/models/product.dart';
import '../../features/supermarkets/data/models/supermarket.dart';

class IsarDatabase {
  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();

    return Isar.open(
      [SupermarketSchema, ProductSchema, PriceEntrySchema],
      directory: dir.path,
      inspector: false,
    );
  }
}
