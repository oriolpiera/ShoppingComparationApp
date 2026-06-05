import 'package:flutter/material.dart';

import '../features/backup/application/backup_import_service.dart';
import '../features/backup/application/backup_share_service.dart';
import '../features/backup/data/file_picker_port_impl.dart';
import '../features/backup/data/file_reader_port_impl.dart';
import '../features/backup/data/file_writer_port_impl.dart';
import '../features/backup/data/path_provider_port_impl.dart';
import '../features/backup/data/share_plus_gateway.dart';
import '../features/backup/data/system_clock.dart';
import '../features/home/presentation/home_page.dart';

class PriceComparatorApp extends StatelessWidget {
  const PriceComparatorApp({
    super.key,
    this.shareService,
    this.importService,
  });

  /// Optional override for the backup share service. When null, a default
  /// service is built using the production [SystemClock],
  /// [PathProviderPortImpl], [SharePlusGateway], and [FileWriterPortImpl].
  final BackupShareService? shareService;

  /// Optional override for the backup import service. When null, a default
  /// service is built using the production [FilePickerPortImpl] and
  /// [FileReaderPortImpl].
  final BackupImportService? importService;

  @override
  Widget build(BuildContext context) {
    final resolvedShare = shareService ?? _defaultShareService();
    final resolvedImport = importService ?? _defaultImportService();
    return MaterialApp(
      title: 'Price Comparator',
      theme: ThemeData(useMaterial3: true),
      home: HomePage(
        shareService: resolvedShare,
        importService: resolvedImport,
      ),
    );
  }

  static BackupShareService _defaultShareService() => BackupShareService(
        clock: const SystemClock(),
        pathProvider: const PathProviderPortImpl(),
        shareGateway: const SharePlusGateway(),
        fileWriter: const FileWriterPortImpl(),
      );

  static BackupImportService _defaultImportService() => BackupImportService(
        filePicker: const FilePickerPortImpl(),
        fileReader: const FileReaderPortImpl(),
      );
}
