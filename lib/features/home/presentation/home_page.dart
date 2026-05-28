import 'package:flutter/material.dart';

import '../../../core/database/isar_database.dart';
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
    AppDatabaseProvider.instance,
  );

  late final DemoSeedService _seedService = DemoSeedService(repository);
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    if (_isWebPreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _seedDemoData(showSnackBar: false);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSeeding ? null : _seedDemoData,
        icon: _isSeeding
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.data_array),
        label: Text(_isSeeding ? 'Seeding...' : 'Seed demo'),
      ),
    );
  }

  Future<void> _seedDemoData({bool showSnackBar = true}) async {
    setState(() => _isSeeding = true);
    try {
      await _seedService.seed();
      if (!mounted) return;
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data ready')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
