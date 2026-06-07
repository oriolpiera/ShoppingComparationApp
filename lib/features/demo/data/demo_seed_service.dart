import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/entities/shopping_list_entry.dart';
import '../../persistence/domain/repositories/product_family_repository.dart';
import '../../persistence/domain/repositories/product_item_repository.dart';
import '../../persistence/domain/repositories/shopping_list_repository.dart';
import '../../persistence/domain/repositories/supermarket_repository.dart';
import '../../persistence/domain/entities/supermarket.dart';

class DemoSeedService {
  final SupermarketRepository supermarketRepository;
  final ProductFamilyRepository productFamilyRepository;
  final ProductItemRepository productItemRepository;
  final ShoppingListRepository shoppingListRepository;

  const DemoSeedService({
    required this.supermarketRepository,
    required this.productFamilyRepository,
    required this.productItemRepository,
    required this.shoppingListRepository,
  });

  Future<void> seed() async {
    final existingSupermarkets = await supermarketRepository.getSupermarkets(
      onlyActive: false,
    );

    if (existingSupermarkets.isNotEmpty) {
      return;
    }

    final supermarketEsclat = await supermarketRepository.saveSupermarket(
      Supermarket(name: 'Esclat', address: 'Olot'),
    );
    final supermarketLidl = await supermarketRepository.saveSupermarket(
      Supermarket(name: 'Lidl', address: 'Olot'),
    );
    await supermarketRepository.saveSupermarket(
      Supermarket(name: 'Aldi', address: 'Olot'),
    );
    await supermarketRepository.saveSupermarket(
      Supermarket(name: 'Consum', address: 'Olot'),
    );
    await supermarketRepository.saveSupermarket(
      Supermarket(name: 'Caprabo', address: 'Les Preses'),
    );

    await productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Xocolata 80%'),
    );
    final familyXoco50 = await productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Xocolata 50%'),
    );
    await productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Plàtan canàries'),
    );
    final familiCivada = await productFamilyRepository.saveProductFamily(
      const ProductFamily(name: 'Civada'),
    );

    await productItemRepository.saveProductItem(
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

    await productItemRepository.saveProductItem(
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

    await productItemRepository.saveProductItem(
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

    await productItemRepository.saveProductItem(
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

    await shoppingListRepository.saveShoppingNeedEntry(
      ShoppingListEntry(
        productFamilyId: familyXoco50,
        quantity: 2,
      ),
    );
    await shoppingListRepository.saveShoppingNeedEntry(
      ShoppingListEntry(
        productFamilyId: familiCivada,
        quantity: 1,
      ),
    );
  }
}
