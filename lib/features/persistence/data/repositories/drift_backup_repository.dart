import 'package:drift/drift.dart';

import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import '../backup/app_data_backup.dart';

class DriftBackupRepository {
  final PersistenceDao dao;

  DriftBackupRepository(this.dao);

  Future<String> exportBackupJson() async {
    final payload = await _buildBackupPayload();
    return payload.toJsonString();
  }

  Future<void> importBackupJson(String jsonPayload) async {
    final payload = AppDataBackup.fromJsonString(jsonPayload);

    await dao.db.transaction(() async {
      await _clearBackupScope();
      await _restoreBackupPayload(payload);
    });
  }

  Future<AppDataBackup> _buildBackupPayload() async {
    final supermarketRows = await dao.db.select(dao.db.supermarketTable).get();
    final familyRows = await dao.db.select(dao.db.productFamilyTable).get();
    final catalogProductRows =
        await dao.db.select(dao.db.catalogProductTable).get();
    final priceRecordRows = await dao.db.select(dao.db.priceRecordTable).get();
    final shoppingListRows =
        await dao.db.select(dao.db.shoppingListTable).get();

    return AppDataBackup(
      schemaVersion: AppDataBackup.currentSchemaVersion,
      exportedAt: DateTime.now().toUtc(),
      supermarkets: supermarketRows
          .map(
            (row) => BackupSupermarket(
              id: row.id,
              name: row.nom,
              address: row.adreca,
              isActive: row.actiu,
            ),
          )
          .toList(),
      productFamilies: familyRows
          .map(
            (row) => BackupProductFamily(
              id: row.id,
              name: row.nom,
              isActive: row.actiu,
              shoppingUnit: row.shoppingUnit,
              purchaseMode: row.purchaseMode,
            ),
          )
          .toList(),
      catalogProducts: catalogProductRows
          .map(
            (row) => BackupCatalogProduct(
              id: row.id,
              name: row.nom,
              isActive: row.actiu,
              productFamilyId: row.productFamilyId,
              barcode: row.barcode,
              packageQuantityAmount: row.packageQuantityAmount,
              packageQuantityUnit: row.packageQuantityUnit,
              normalizedMeasurementUnit: row.normalizedMeasurementUnit,
              identityKey: row.identityKey,
            ),
          )
          .toList(),
      priceRecords: priceRecordRows
          .map(
            (row) => BackupPriceRecord(
              id: row.id,
              catalogProductId: row.catalogProductId,
              supermarketId: row.supermarketId,
              price: row.price,
              observedAt: row.observedAt,
              isActive: row.actiu,
            ),
          )
          .toList(),
      shoppingListEntries: shoppingListRows
          .map(
            (row) => BackupShoppingListEntry(
              id: row.id,
              productFamilyId: row.productFamilyId,
              quantity: row.quantity,
            ),
          )
          .toList(),
    );
  }

  Future<void> _clearBackupScope() async {
    await dao.db.customStatement('PRAGMA foreign_keys = OFF;');
    try {
      await dao.db.batch((batch) {
        batch.deleteAll(dao.db.shoppingListTable);
        batch.deleteAll(dao.db.priceRecordTable);
        batch.deleteAll(dao.db.catalogProductTable);
        batch.deleteAll(dao.db.productItemTable);
        batch.deleteAll(dao.db.productFamilyTable);
        batch.deleteAll(dao.db.supermarketTable);
      });
    } finally {
      await dao.db.customStatement('PRAGMA foreign_keys = ON;');
    }
  }

  Future<void> _restoreBackupPayload(AppDataBackup payload) async {
    await dao.db.batch((batch) {
      batch.insertAll(
        dao.db.supermarketTable,
        payload.supermarkets
            .map(
              (row) => SupermarketTableCompanion(
                id: Value(row.id),
                nom: Value(row.name),
                adreca: Value(row.address),
                actiu: Value(row.isActive),
              ),
            )
            .toList(),
      );
      batch.insertAll(
        dao.db.productFamilyTable,
        payload.productFamilies
            .map(
              (row) => ProductFamilyTableCompanion(
                id: Value(row.id),
                nom: Value(row.name),
                actiu: Value(row.isActive),
                shoppingUnit: Value(row.shoppingUnit),
                purchaseMode: Value(row.purchaseMode),
              ),
            )
            .toList(),
      );
      batch.insertAll(
        dao.db.catalogProductTable,
        payload.catalogProducts
            .map(
              (row) => CatalogProductTableCompanion(
                id: Value(row.id),
                nom: Value(row.name),
                actiu: Value(row.isActive),
                productFamilyId: Value(row.productFamilyId),
                barcode: Value(row.barcode),
                packageQuantityAmount: Value(row.packageQuantityAmount),
                packageQuantityUnit: Value(row.packageQuantityUnit),
                normalizedMeasurementUnit: Value(row.normalizedMeasurementUnit),
                identityKey: Value(row.identityKey),
              ),
            )
            .toList(),
      );
      batch.insertAll(
        dao.db.priceRecordTable,
        payload.priceRecords
            .map(
              (row) => PriceRecordTableCompanion(
                id: Value(row.id),
                catalogProductId: Value(row.catalogProductId),
                supermarketId: Value(row.supermarketId),
                price: Value(row.price),
                observedAt: Value(row.observedAt),
                actiu: Value(row.isActive),
                externalObservationId: const Value.absent(),
              ),
            )
            .toList(),
      );
      batch.insertAll(
        dao.db.shoppingListTable,
        payload.shoppingListEntries
            .map(
              (row) => ShoppingListTableCompanion(
                id: Value(row.id),
                productFamilyId: Value(row.productFamilyId),
                quantity: Value(row.quantity),
                productItemId: const Value.absent(),
              ),
            )
            .toList(),
      );
    });
  }
}
