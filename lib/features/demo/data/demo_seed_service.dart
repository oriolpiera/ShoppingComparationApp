import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/entities/shopping_list_entry.dart';
import '../../persistence/domain/repositories/persistence_repository.dart';
import '../../supermarkets/data/models/supermarket.dart';

class DemoSeedService {
  final PersistenceRepository repository;

  const DemoSeedService(this.repository);

  Future<void> seed() async {
    final existingSupermarkets = await repository.getSupermarkets(
      onlyActive: false,
    );

    if (existingSupermarkets.isNotEmpty) {
      return;
    }

    final supermarketEsclat = await repository.saveSupermarket(
      Supermarket(name: 'Esclat', address: 'Olot'),
    );
    final supermarketLidl = await repository.saveSupermarket(
      Supermarket(name: 'Lidl', address: 'Olot'),
    );
    await repository.saveSupermarket(
      Supermarket(name: 'Aldi', address: 'Olot'),
    );
    await repository.saveSupermarket(
      Supermarket(name: 'Consum', address: 'Olot'),
    );
    await repository.saveSupermarket(
      Supermarket(name: 'Caprabo', address: 'Les Preses'),
    );

    await repository.saveProductFamily(
      const ProductFamily(name: 'Xocolata 80%'),
    );
    final familyXoco50 = await repository.saveProductFamily(
      const ProductFamily(name: 'Xocolata 50%'),
    );
    await repository.saveProductFamily(
      const ProductFamily(name: 'Plàtan canàries'),
    );
    final familiCivada = await repository.saveProductFamily(
      const ProductFamily(name: 'Civada'),
    );

    final itemXoco50Lidl = await repository.saveProductItem(
      ProductItem(
        name: 'Xocolata 50% 100g',
        productFamilyId: familyXoco50,
        supermarketId: supermarketLidl,
        price: 0.95,
        quantity: 0.1,
        unitType: 'kg',
        pricePerQuantity: 0.85,
        dateAdded: DateTime.now(),
        isCurrentPrice: true,
        barcode: '3333333333333',
      ),
    );

    await repository.saveProductItem(
      ProductItem(
        name: 'Xocolata 50% 200g',
        productFamilyId: familyXoco50,
        supermarketId: supermarketEsclat,
        price: 2.90,
        quantity: 0.2,
        unitType: 'kg',
        pricePerQuantity: 0.90,
        dateAdded: DateTime.now(),
        isCurrentPrice: true,
        barcode: '3333333333333',
      ),
    );

    final itemCivadaLidl = await repository.saveProductItem(
      ProductItem(
        name: 'Civada 1kg',
        productFamilyId: familiCivada,
        supermarketId: supermarketLidl,
        price: 0.50,
        quantity: 1,
        unitType: 'kg',
        pricePerQuantity: 0.50,
        dateAdded: DateTime.now(),
        isCurrentPrice: true,
        barcode: '5555555555555',
      ),
    );

    await repository.saveProductItem(
      ProductItem(
        name: 'Civada 500g',
        productFamilyId: familiCivada,
        supermarketId: supermarketEsclat,
        price: 1.30,
        quantity: 0.5,
        unitType: 'kg',
        pricePerQuantity: 0.60,
        dateAdded: DateTime.now(),
        isCurrentPrice: true,
        barcode: '5555555555555',
      ),
    );

    await repository.saveShoppingListEntry(
      ShoppingListEntry(
        productFamilyId: familyXoco50,
        quantity: 2,
        productItemId: itemXoco50Lidl,
      ),
    );
    await repository.saveShoppingListEntry(
      ShoppingListEntry(
        productFamilyId: familiCivada,
        quantity: 1,
        productItemId: itemCivadaLidl,
      ),
    );
  }
}
