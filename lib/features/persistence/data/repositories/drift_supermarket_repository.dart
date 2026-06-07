import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../../domain/entities/supermarket.dart';
import '../../domain/repositories/supermarket_repository.dart';

class DriftSupermarketRepository implements SupermarketRepository {
  final PersistenceDao dao;

  DriftSupermarketRepository(this.dao);

  @override
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

  @override
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

  @override
  Future<int?> getLastUsedSupermarketId() async {
    final row = await dao.db
        .customSelect(
          'SELECT supermarket_id FROM price_record ORDER BY observed_at DESC, id DESC LIMIT 1;',
        )
        .getSingleOrNull();
    if (row == null) return null;
    return row.read<int>('supermarket_id');
  }
}
