import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../../core/database/drift_database_provider.dart';
import '../../demo/data/demo_seed_service.dart';
import '../../persistence/data/repositories/drift_persistence_repository.dart';
import 'model_records_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    if (_isWebPreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(DemoSeedService(repository).seed());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Comparator')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Supermarkets'),
            onTap: () =>
                _open(context, SupermarketsPage(repository: repository)),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Product families'),
            onTap: () =>
                _open(context, ProductFamiliesPage(repository: repository)),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Product items'),
            onTap: () =>
                _open(context, ProductItemsPage(repository: repository)),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('Shopping list'),
            onTap: () =>
                _open(context, ShoppingListPage(repository: repository)),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
