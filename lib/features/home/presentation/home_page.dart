import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../core/database/drift_database_provider.dart';
import '../../backup/application/backup_import_service.dart';
import '../../backup/application/backup_share_service.dart';
import '../../backup/presentation/data_backup_page.dart';
import '../../demo/data/demo_seed_service.dart';
import '../../persistence/data/repositories/drift_persistence_repository.dart';
import 'pages/product_families_page.dart';
import 'pages/product_items_page.dart';
import 'pages/shopping_list_page.dart';
import 'pages/supermarkets_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.shareService, this.importService});

  /// Service used by the Data Backup page to share the exported JSON as
  /// a file. When null, the page falls back to its clipboard-only path.
  final BackupShareService? shareService;

  /// Service used by the Data Backup page to import a backup from a file
  /// picked through the OS file picker. When null, the page hides the
  /// "Pick backup file" button and keeps only the paste-based flow.
  final BackupImportService? importService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _isWebPreview = bool.fromEnvironment('WEB_PREVIEW');

  final repository = DriftPersistenceRepository.fromDatabase(
    AppDriftDatabaseProvider.instance,
  );

  @override
  void initState() {
    super.initState();
    if (_isWebPreview || kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          DemoSeedService(
            supermarketRepository: repository.supermarketRepository,
            productFamilyRepository: repository.productFamilyRepository,
            productItemRepository: repository.priceRecordRepository,
            shoppingListRepository: repository.shoppingListRepository,
          ).seed(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareService = widget.shareService;
    final importService = widget.importService;
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Comparator')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Supermarkets'),
            onTap: () => _open(context,
                SupermarketsPage(repository: repository.supermarketRepository)),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Product families'),
            onTap: () => _open(
              context,
              ProductFamiliesPage(
                productFamilyRepository: repository.productFamilyRepository,
                productItemRepository: repository.priceRecordRepository,
                supermarketRepository: repository.supermarketRepository,
                shoppingListRepository: repository.shoppingListRepository,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('Shopping list'),
            onTap: () => _open(
              context,
              ShoppingListPage(
                shoppingListRepository: repository.shoppingListRepository,
                productFamilyRepository: repository.productFamilyRepository,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Product items'),
            onTap: () => _open(
                context,
                ProductItemsPage(
                  productItemRepository: repository.priceRecordRepository,
                  productFamilyRepository: repository.productFamilyRepository,
                  supermarketRepository: repository.supermarketRepository,
                  priceRecordRepository: repository.priceRecordRepository,
                )),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Data backup'),
            onTap: () => _open(
              context,
              DataBackupPage(
                repository: repository.backupRepository,
                onSharePressed: shareService == null
                    ? null
                    : (json) => shareService.shareBackupJson(json),
                onPickFilePressed: importService == null
                    ? null
                    : () => importService.pickAndRead(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
