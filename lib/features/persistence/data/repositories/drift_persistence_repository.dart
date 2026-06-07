import '../../../../core/database/dao/persistence_dao.dart';
import '../../../../core/database/drift_database.dart';
import 'drift_backup_repository.dart';
import 'drift_external_observation_repository.dart';
import 'drift_price_record_repository.dart';
import 'drift_product_family_repository.dart';
import 'drift_shopping_list_repository.dart';
import 'drift_supermarket_repository.dart';

class DriftPersistenceRepository {
  final DriftSupermarketRepository _supermarketRepository;
  final DriftProductFamilyRepository _productFamilyRepository;
  final DriftPriceRecordRepository _priceRecordRepository;
  final DriftShoppingListRepository _shoppingListRepository;
  final DriftExternalObservationRepository _externalObservationRepository;
  final DriftBackupRepository _backupRepository;

  DriftPersistenceRepository._({
    required DriftSupermarketRepository supermarketRepository,
    required DriftProductFamilyRepository productFamilyRepository,
    required DriftPriceRecordRepository priceRecordRepository,
    required DriftShoppingListRepository shoppingListRepository,
    required DriftExternalObservationRepository externalObservationRepository,
    required DriftBackupRepository backupRepository,
  })  : _supermarketRepository = supermarketRepository,
        _productFamilyRepository = productFamilyRepository,
        _priceRecordRepository = priceRecordRepository,
        _shoppingListRepository = shoppingListRepository,
        _externalObservationRepository = externalObservationRepository,
        _backupRepository = backupRepository;

  factory DriftPersistenceRepository(PersistenceDao dao) {
    final supermarketRepository = DriftSupermarketRepository(dao);
    final productFamilyRepository = DriftProductFamilyRepository(dao);
    final priceRecordRepository = DriftPriceRecordRepository(
      dao,
    );
    final externalObservationRepository = DriftExternalObservationRepository(
      dao,
      productFamilyRepository: productFamilyRepository,
      productItemRepository: priceRecordRepository,
    );
    return DriftPersistenceRepository._(
      supermarketRepository: supermarketRepository,
      productFamilyRepository: productFamilyRepository,
      priceRecordRepository: priceRecordRepository,
      shoppingListRepository: DriftShoppingListRepository(
        dao,
        productFamilyRepository: productFamilyRepository,
        supermarketRepository: supermarketRepository,
        productItemRepository: priceRecordRepository,
        externalObservationRepository: externalObservationRepository,
      ),
      externalObservationRepository: externalObservationRepository,
      backupRepository: DriftBackupRepository(dao),
    );
  }

  factory DriftPersistenceRepository.fromDatabase(AppDriftDatabase db) {
    return DriftPersistenceRepository(PersistenceDao(db));
  }

  // ---------------------------------------------------------------------------
  // Exposed sub-repositories for selective dependency injection
  // ---------------------------------------------------------------------------

  DriftSupermarketRepository get supermarketRepository =>
      _supermarketRepository;
  DriftProductFamilyRepository get productFamilyRepository =>
      _productFamilyRepository;
  DriftPriceRecordRepository get priceRecordRepository =>
      _priceRecordRepository;
  DriftShoppingListRepository get shoppingListRepository =>
      _shoppingListRepository;
  DriftExternalObservationRepository get externalObservationRepository =>
      _externalObservationRepository;
  DriftBackupRepository get backupRepository => _backupRepository;
}
