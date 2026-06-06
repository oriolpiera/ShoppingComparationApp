import 'package:flutter/material.dart';

import '../../../persistence/domain/repositories/persistence_repository.dart';
import '../../../persistence/domain/entities/supermarket.dart';

class SupermarketsPage extends StatefulWidget {
  const SupermarketsPage({super.key, required this.repository});

  final PersistenceRepository repository;

  @override
  State<SupermarketsPage> createState() => _SupermarketsPageState();
}

class _SupermarketsPageState extends State<SupermarketsPage> {
  final _queryController = TextEditingController();
  late Future<List<Supermarket>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<List<Supermarket>> _load() {
    return widget.repository.getSupermarkets(onlyActive: true);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supermarkets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _queryController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Supermarket>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final query = _queryController.text.toLowerCase().trim();
                final supermarkets = (snapshot.data ?? const []).where((s) {
                  if (query.isEmpty) return true;
                  return s.name.toLowerCase().contains(query) ||
                      (s.address ?? '').toLowerCase().contains(query);
                }).toList();

                if (supermarkets.isEmpty) {
                  return const Center(child: Text('No supermarkets'));
                }

                return ListView.separated(
                  itemCount: supermarkets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = supermarkets[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(item.address ?? '-'),
                      onTap: () async {
                        final action = await Navigator.of(context)
                            .push<_SupermarketDetailsAction>(
                          MaterialPageRoute(
                            builder: (_) => _SupermarketDetailsPage(item: item),
                          ),
                        );

                        if (!mounted) return;

                        if (action == _SupermarketDetailsAction.edit) {
                          await _openForm(item);
                        } else if (action == _SupermarketDetailsAction.delete) {
                          await widget.repository.saveSupermarket(
                            Supermarket(
                              id: item.id,
                              name: item.name,
                              address: item.address,
                              isActive: false,
                            ),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Supermarket deleted'),
                            ),
                          );
                        }

                        _refresh();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(Supermarket? supermarket) async {
    final nameController = TextEditingController(text: supermarket?.name ?? '');
    final addressController =
        TextEditingController(text: supermarket?.address ?? '');

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          supermarket == null ? 'Add supermarket' : 'Edit supermarket',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (save == true && nameController.text.trim().isNotEmpty) {
      await widget.repository.saveSupermarket(
        Supermarket(
          id: supermarket?.id,
          name: nameController.text.trim(),
          address: addressController.text.trim().isEmpty
              ? null
              : addressController.text.trim(),
          isActive: true,
        ),
      );
      _refresh();
    }
  }
}

enum _SupermarketDetailsAction { edit, delete }

class _SupermarketDetailsPage extends StatelessWidget {
  const _SupermarketDetailsPage({required this.item});

  final Supermarket item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supermarket details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pop(context, _SupermarketDetailsAction.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailRow(label: 'Name', value: item.name),
          _DetailRow(
            label: 'Address',
            value: item.address?.trim().isEmpty == true
                ? '—'
                : (item.address ?? '—'),
          ),
          _DetailRow(label: 'Active', value: item.isActive ? 'Yes' : 'No'),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete supermarket?'),
                  content: const Text(
                    'This will mark the supermarket as inactive.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true && context.mounted) {
                Navigator.pop(context, _SupermarketDetailsAction.delete);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
