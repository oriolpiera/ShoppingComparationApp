import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../persistence/domain/repositories/persistence_repository.dart';
import '../application/backup_import_service.dart';
import '../application/backup_share_service.dart';

class DataBackupPage extends StatefulWidget {
  const DataBackupPage({
    super.key,
    required this.repository,
    this.onExported,
    this.copyToClipboard,
    this.onSharePressed,
    this.onPickFilePressed,
  });

  final PersistenceRepository repository;

  /// Optional async callback invoked after a successful share with the JSON
  /// payload that was handed to the share sheet.
  final Future<void> Function(String jsonPayload)? onExported;

  /// Optional async callback invoked for the secondary "Copy JSON" action.
  /// When null, the page uses [defaultCopyToClipboard] as a default.
  final Future<void> Function(String jsonPayload)? copyToClipboard;

  /// Optional async callback invoked when the primary "Share backup file"
  /// button is tapped. The page hands the JSON payload; the caller is
  /// responsible for staging the file and presenting the share sheet
  /// (typically via [BackupShareService]). The page also calls [onExported]
  /// after a successful share.
  final Future<void> Function(String jsonPayload)? onSharePressed;

  /// Optional async callback invoked when the primary "Pick backup file"
  /// button is tapped. The callback is expected to open the OS file picker
  /// and read the chosen file (typically via [BackupImportService]) and
  /// return its JSON contents, or `null` if the user cancelled.
  ///
  /// When the callback throws a [BackupImportException] (or any other
  /// error), the page shows the exception's user-facing message in a
  /// snackbar and leaves the existing textarea unchanged.
  final Future<String?> Function()? onPickFilePressed;

  /// Default implementation used by the secondary "Copy JSON" action when
  /// no [copyToClipboard] is provided. Tests can override this to avoid the
  /// platform `Clipboard.setData` channel; production wiring leaves it
  /// untouched.
  @visibleForTesting
  static Future<void> Function(String jsonPayload) defaultCopyToClipboard =
      (json) => Clipboard.setData(ClipboardData(text: json));

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
                    'Export your saved supermarkets, product families, products, price history, and shopping list as JSON. The backup is shared as a `.json` file you can save or send to another app.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _shareBackup,
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Share backup file'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isBusy ? null : _exportData,
                    child: const Text('Copy JSON to clipboard'),
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
                    'Pick a previously exported backup file from your device, or paste its contents below. Any file can be selected; the app validates the content and shows an error if it isn\'t a recognized backup. Importing replaces the backed-up supermarkets, product families, products, price history, and shopping list.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _isBusy || widget.onPickFilePressed == null
                        ? null
                        : _pickAndImport,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Pick backup file'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Or paste the JSON contents:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
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
                    'Warning: importing replaces the backed-up saved data in this app. Data not included in the backup file is kept as-is. This cannot be undone.',
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

  Future<void> _shareBackup() async {
    await _runBusyAction(() async {
      final backupJson = await widget.repository.exportBackupJson();
      final share = widget.onSharePressed;
      if (share != null) {
        await share(backupJson);
      }
      if (!mounted) return;
      if (widget.onExported != null) {
        await widget.onExported!(backupJson);
      }
      if (!mounted) return;
      _showMessage('Backup file ready to share');
    });
  }

  Future<void> _exportData() async {
    await _runBusyAction(() async {
      final backupJson = await widget.repository.exportBackupJson();
      final copyToClipboard =
          widget.copyToClipboard ?? DataBackupPage.defaultCopyToClipboard;
      await copyToClipboard(backupJson);
      if (widget.onExported != null) {
        await widget.onExported!(backupJson);
      }

      if (!mounted) return;
      _showMessage('Backup JSON copied to clipboard');
    });
  }

  Future<void> _confirmImport() async {
    final confirmed = await _confirmReplacement();
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

  Future<void> _pickAndImport() async {
    final picker = widget.onPickFilePressed;
    if (picker == null) return;

    await _runBusyAction(() async {
      final json = await picker();
      if (json == null) return;
      if (!mounted) return;

      final confirmed = await _confirmReplacement();
      if (confirmed != true) return;

      await widget.repository.importBackupJson(json);
      if (!mounted) return;
      _importController.text = json;
      _showMessage('Backup imported successfully');
    });
  }

  Future<bool> _confirmReplacement() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Replace current data?'),
          content: const Text(
            'Importing a backup replaces the current supermarkets, product families, saved products, price history, and shopping list included in the backup file. Other stored data remains unchanged.',
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
    return confirmed == true;
  }

  Future<T?> _runBusyAction<T>(Future<T> Function() action) async {
    if (_isBusy) return null;

    setState(() => _isBusy = true);
    try {
      return await action();
    } on FormatException catch (error) {
      if (!mounted) return null;
      _showMessage('Invalid backup file: ${error.message}');
      return null;
    } on BackupShareException catch (error) {
      if (!mounted) return null;
      _showMessage(error.userMessage);
      return null;
    } on BackupImportException catch (error) {
      if (!mounted) return null;
      _showMessage(error.userMessage);
      return null;
    } catch (error) {
      if (!mounted) return null;
      _showMessage('Backup action failed: $error');
      return null;
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
}
