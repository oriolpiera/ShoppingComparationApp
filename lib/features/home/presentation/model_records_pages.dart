import 'package:flutter/material.dart';

import '../../persistence/domain/entities/product_family.dart';
import '../../persistence/domain/entities/product_item.dart';
import '../../persistence/domain/entities/shopping_list_entry.dart';
import '../../persistence/domain/repositories/persistence_repository.dart';
import '../../supermarkets/data/models/supermarket.dart';

class SupermarketsPage extends StatelessWidget {
  const SupermarketsPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  Widget build(BuildContext context) {
    return _RecordsScaffold<Supermarket>(
      title: 'Supermarkets',
      future: repository.getSupermarkets(onlyActive: false),
      itemBuilder: (item) =>
          'ID ${item.id ?? '-'} · ${item.name} · ${item.address ?? '-'}',
    );
  }
}

class ProductFamiliesPage extends StatelessWidget {
  const ProductFamiliesPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  Widget build(BuildContext context) {
    return _RecordsScaffold<ProductFamily>(
      title: 'Product families',
      future: repository.getProductFamilies(onlyActive: false),
      itemBuilder: (item) =>
          'ID ${item.id ?? '-'} · ${item.name} · active: ${item.isActive}',
    );
  }
}

class ProductItemsPage extends StatelessWidget {
  const ProductItemsPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  Widget build(BuildContext context) {
    return _RecordsScaffold<ProductItem>(
      title: 'Product items',
      future: repository.getProductItems(onlyCurrentPrice: false),
      itemBuilder: (item) =>
          'ID ${item.id ?? '-'} · ${item.name} · €${item.price.toStringAsFixed(2)} · ${item.quantity} ${item.unitType}',
    );
  }
}

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  Widget build(BuildContext context) {
    return _RecordsScaffold<ShoppingListEntry>(
      title: 'Shopping list',
      future: repository.getShoppingList(),
      itemBuilder: (item) =>
          'ID ${item.id ?? '-'} · family ${item.productFamilyId} · item ${item.productItemId} · qty ${item.quantity}',
    );
  }
}

class _RecordsScaffold<T> extends StatelessWidget {
  const _RecordsScaffold({
    required this.title,
    required this.future,
    required this.itemBuilder,
  });

  final String title;
  final Future<List<T>> future;
  final String Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<T>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? const [];
          if (data.isEmpty) {
            return const Center(child: Text('No records yet'));
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => ListTile(
              dense: true,
              title: Text(itemBuilder(data[index])),
            ),
          );
        },
      ),
    );
  }
}
