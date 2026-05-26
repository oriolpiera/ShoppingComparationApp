import '../../prices/data/models/price_entry.dart';
import '../../products/data/models/product.dart';
import '../../supermarkets/data/models/supermarket.dart';

class DemoDataService {
  const DemoDataService();

  Future<List<Supermarket>> sampleSupermarkets() async {
    return <Supermarket>[
      Supermarket()..name = 'Mercat A',
      Supermarket()..name = 'Mercat B',
    ];
  }

  Future<List<Product>> sampleProducts() async {
    return <Product>[
      (Product()
        ..name = 'Milk 1L'
        ..barcode = '1111111111111'),
      (Product()
        ..name = 'Bread'
        ..barcode = '2222222222222'),
    ];
  }

  Future<List<PriceEntry>> samplePrices() async {
    final now = DateTime.now();
    return <PriceEntry>[
      PriceEntry()
        ..productId = 1
        ..supermarketId = 1
        ..price = 1.25
        ..capturedAt = now,
      PriceEntry()
        ..productId = 1
        ..supermarketId = 2
        ..price = 1.15
        ..capturedAt = now,
    ];
  }
}
