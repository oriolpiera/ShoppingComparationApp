import '../entities/supermarket.dart';

abstract class SupermarketRepository {
  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true});

  Future<int> saveSupermarket(Supermarket supermarket);

  Future<int?> getLastUsedSupermarketId();
}
