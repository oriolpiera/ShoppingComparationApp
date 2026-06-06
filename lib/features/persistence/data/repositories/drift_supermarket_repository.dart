import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../domain/entities/supermarket.dart';

class DriftSupermarketRepository {
  final PersistenceDao dao;

  DriftSupermarketRepository(this.dao);

  Future<List<Supermarket>> getSupermarkets({bool onlyActive = true}) async {
    final rows = await dao.getSupermarkets(onlyActive: onlyActive);
    return rows
        .map(
          (row) => Supermarket(
            id: row.id,
            name: row.nom,
            address: row.adreca,
            isActive: row.actiu,
          ),
        )
        .toList();
  }

  Future<int> saveSupermarket(Supermarket supermarket) {
    return dao.saveSupermarket(
      SupermarketTableCompanion(
        id: supermarket.id == null
            ? const Value.absent()
            : Value(supermarket.id!),
        nom: Value(supermarket.name),
        adreca: Value(supermarket.address),
        actiu: Value(supermarket.isActive),
      ),
    );
  }
}
