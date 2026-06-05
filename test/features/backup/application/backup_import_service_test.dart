import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/backup/application/backup_import_service.dart';
import 'package:shopping_comparation_app/features/backup/domain/ports/file_picker_port.dart';
import 'package:shopping_comparation_app/features/backup/domain/ports/file_reader_port.dart';

void main() {
  group('pickAndRead', () {
    late FakeFilePicker filePicker;
    late FakeFileReader fileReader;
    late BackupImportService service;

    setUp(() {
      filePicker = FakeFilePicker();
      fileReader = FakeFileReader();
      service = BackupImportService(
        filePicker: filePicker,
        fileReader: fileReader,
      );
    });

    test('pickAndRead_returnsNullWhenPickerReturnsNull', () async {
      filePicker.picked = null;

      final result = await service.pickAndRead();

      expect(result, isNull);
      expect(fileReader.reads, isEmpty);
    });

    test('pickAndRead_returnsFileContentOnHappyPath', () async {
      filePicker.picked =
          (path: '/storage/shopping.json', name: 'shopping.json');
      fileReader.contents['/storage/shopping.json'] = '{"hello":"world"}';

      final result = await service.pickAndRead();

      expect(result, '{"hello":"world"}');
      expect(fileReader.reads, ['/storage/shopping.json']);
    });

    test('pickAndRead_propagatesReaderErrorAsBackupImportException', () async {
      filePicker.picked =
          (path: '/storage/shopping.json', name: 'shopping.json');
      final cause = const FileSystemException('permission denied');
      fileReader.errors['/storage/shopping.json'] = cause;

      try {
        await service.pickAndRead();
        fail('expected BackupImportException');
      } on BackupImportException catch (e) {
        expect(e.cause, same(cause));
        expect(e.userMessage, contains('backup file'));
      }
    });

    test('pickAndRead_propagatesPickerErrorAsBackupImportException', () async {
      final cause = StateError('picker crashed');
      filePicker.errorToThrow = cause;

      try {
        await service.pickAndRead();
        fail('expected BackupImportException');
      } on BackupImportException catch (e) {
        expect(e.cause, same(cause));
        expect(e.userMessage, contains('backup file'));
      }
    });

    test('pickAndRead_inFlightGuardReturnsNullOnSecondCall', () async {
      final gate = Completer<void>();
      filePicker.delay = gate.future;
      filePicker.picked =
          (path: '/storage/shopping.json', name: 'shopping.json');
      fileReader.contents['/storage/shopping.json'] = '{}';

      final first = service.pickAndRead();
      final second = await service.pickAndRead();

      gate.complete();
      final firstResult = await first;

      expect(second, isNull);
      expect(firstResult, '{}');
    });
  });

  test('pickAndRead_doesNotImportDartIoInApplicationLayer', () {
    final source = File(
      'lib/features/backup/application/backup_import_service.dart',
    ).readAsStringSync();

    expect(
      source.contains("import 'dart:io'"),
      isFalse,
      reason: 'application layer must not import dart:io',
    );
    expect(
      RegExp(r'\bdart:io\b').hasMatch(source),
      isFalse,
      reason: 'application layer must not reference dart:io at all',
    );
  });
}

class FakeFilePicker implements FilePickerPort {
  PickedBackupFile? picked;
  Object? errorToThrow;
  Future<void>? delay;
  final List<int> pickCalls = [];
  int _callIndex = 0;

  @override
  Future<PickedBackupFile?> pickJsonBackup() async {
    final callIndex = _callIndex++;
    pickCalls.add(callIndex);
    if (delay != null) {
      await delay;
    }
    if (errorToThrow != null) throw errorToThrow!;
    return picked;
  }
}

class FakeFileReader implements FileReaderPort {
  final Map<String, String> contents = {};
  final Map<String, Object> errors = {};
  final List<String> reads = [];

  @override
  Future<String> readAsString(String path) async {
    reads.add(path);
    final err = errors[path];
    if (err != null) throw err;
    return contents[path] ?? '';
  }
}
