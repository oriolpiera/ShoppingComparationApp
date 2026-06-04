import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../persistence/domain/repositories/persistence_repository.dart';

class DataBackupPage extends StatefulWidget {
  const DataBackupPage({
    super.key,
    required this.repository,
    this.onExported,
    this.copyToClipboard,
  });

  final PersistenceRepository repository;
  final Future<void> Function(String jsonPayload)? onExported;
  final Future<void> Function(String jsonPayload)? copyToClipboard;

  @override
  State<DataBackupPage> createState() => _DataBackupPageState();
}

class _DataBackupPageState extends State<DataBackupPage> {
  bool _isBusy = false;
  final TextEditingController _importController = TextEditingController();

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export your saved supermarkets, product families, products, price history, and shopping list as JSON. The backup is copied to the clipboard so you can save it wherever you want.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _exportData,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Export data'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paste a previously exported JSON backup below to replace the current app data.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _importController,
                    minLines: 8,
                    maxLines: 14,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      labelText: 'Backup JSON',
                      hintText: '{\n  "schemaVersion": 1,\n  ...\n}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _isBusy ? null : _confirmImport,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Import data'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Warning: importing replaces the existing saved data. This cannot be undone.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (_isBusy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    await _runBusyAction(() async {
      final backupJson = await widget.repository.exportBackupJson();
      final copyToClipboard = widget.copyToClipboard ?? _copyToClipboard;
      await copyToClipboard(backupJson);
      if (widget.onExported != null) {
        await widget.onExported!(backupJson);
      }

      if (!mounted) return;
      _showMessage('Backup JSON copied to clipboard');
    });
  }

  Future<void> _confirmImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Replace current data?'),
          content: const Text(
            'Importing a backup replaces the current supermarkets, product families, saved products, and shopping list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Replace data'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _runBusyAction(() async {
      final contents = _importController.text.trim();
      if (contents.isEmpty) {
        if (!mounted) return;
        _showMessage('Paste a backup JSON before importing');
        return;
      }

      await widget.repository.importBackupJson(contents);
      if (!mounted) return;
      _showMessage('Backup imported successfully');
    });
  }

  Future<void> _runBusyAction(Future<void> Function() action) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);
    try {
      await action();
    } on FormatException catch (error) {
      if (!mounted) return;
      _showMessage('Invalid backup file: ${error.message}');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Backup action failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _copyToClipboard(String jsonPayload) {
    return Clipboard.setData(ClipboardData(text: jsonPayload));
  }
}
