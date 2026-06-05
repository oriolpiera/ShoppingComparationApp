import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_comparation_app/features/backup/application/backup_share_service.dart';
import 'package:shopping_comparation_app/features/backup/domain/ports/clock.dart';
import 'package:shopping_comparation_app/features/backup/domain/ports/file_writer_port.dart';
import 'package:shopping_comparation_app/features/backup/domain/ports/path_provider_port.dart';
import 'package:shopping_comparation_app/features/backup/domain/ports/share_gateway.dart';

void main() {
  // Stable "now" used across the test group so filename tests are deterministic.
  final fixedNow = DateTime.utc(2026, 6, 5, 18, 40, 50);

  group('buildBackupFileName', () {
    test('buildBackupFileName_usesCompactUtcTimestamp_fromFixedClock', () {
      expect(
        buildBackupFileName(fixedNow),
        'shopping-backup-20260605T184050Z.json',
      );
    });

    test('buildBackupFileName_containsOnlyAsciiFilenameSafeCharacters', () {
      final name = buildBackupFileName(fixedNow);
      // ASCII letters, digits, '.', '_' and '-' are the only safe characters
      // for cross-platform filenames. No colons, no spaces, no locale chars.
      expect(
        RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(name),
        isTrue,
        reason: 'filename should be ASCII only, got: $name',
      );
    });
  });

  group('shareBackupJson', () {
    late FakeClock clock;
    late FakePathProvider pathProvider;
    late FakeShareGateway shareGateway;
    late FakeFileWriter fileWriter;
    late BackupShareService service;

    setUp(() {
      clock = FakeClock(fixedNow);
      pathProvider = FakePathProvider('/tmp');
      shareGateway = FakeShareGateway();
      fileWriter = FakeFileWriter();
      service = BackupShareService(
        clock: clock,
        pathProvider: pathProvider,
        shareGateway: shareGateway,
        fileWriter: fileWriter,
      );
    });

    test('shareBackupJson_writesJsonToPathProviderTemporaryDirectory',
        () async {
      const json = '{"hello":"world"}';
      await service.shareBackupJson(json);

      expect(fileWriter.writes, hasLength(1));
      final stagedPath = fileWriter.writes.single;
      expect(stagedPath, '/tmp/shopping-backup-20260605T184050Z.json');
      expect(fileWriter.contents[stagedPath], json);
    });

    test('shareBackupJson_invokesShareGatewayWithApplicationJsonMime',
        () async {
      await service.shareBackupJson('{}');

      expect(shareGateway.shared, hasLength(1));
      expect(shareGateway.shared.single, hasLength(1));
      expect(shareGateway.shared.single.single.mimeType, 'application/json');
    });

    test('shareBackupJson_passesMatchingFilenameOverrideToShareGateway',
        () async {
      await service.shareBackupJson('{}');

      expect(shareGateway.overrides, hasLength(1));
      expect(
        shareGateway.overrides.single,
        ['shopping-backup-20260605T184050Z.json'],
      );
    });

    test('shareBackupJson_deletesTemporaryFileOnSuccess', () async {
      await service.shareBackupJson('{}');

      expect(
        fileWriter.deletes,
        ['/tmp/shopping-backup-20260605T184050Z.json'],
      );
    });

    test('shareBackupJson_deletesTemporaryFileOnShareFailure', () async {
      shareGateway.errorToThrow = StateError('user dismissed');

      await expectLater(
        service.shareBackupJson('{}'),
        throwsA(isA<BackupShareException>()),
      );

      expect(
        fileWriter.deletes,
        ['/tmp/shopping-backup-20260605T184050Z.json'],
      );
    });

    test('shareBackupJson_propagatesPathProviderFailureWithoutWritingFile',
        () async {
      pathProvider.errorToThrow = StateError('no temp dir');

      await expectLater(
        service.shareBackupJson('{}'),
        throwsA(isA<BackupShareException>()),
      );

      expect(fileWriter.writes, isEmpty);
      expect(fileWriter.deletes, isEmpty);
    });

    test('shareBackupJson_propagatesShareFailure', () async {
      final cause = StateError('boom');
      shareGateway.errorToThrow = cause;

      try {
        await service.shareBackupJson('{}');
        fail('expected BackupShareException');
      } on BackupShareException catch (e) {
        expect(e.cause, same(cause));
        expect(e.userMessage, contains('backup file'));
      }
    });

    test('shareBackupJson_honorsCustomFileNameOverride', () async {
      await service.shareBackupJson('{}', fileName: 'my-backup.json');

      expect(fileWriter.writes, ['/tmp/my-backup.json']);
      expect(shareGateway.overrides.single, ['my-backup.json']);
    });
  });

  test('shareBackupJson_doesNotImportDartIoInApplicationLayer', () {
    final source = File(
      'lib/features/backup/application/backup_share_service.dart',
    ).readAsStringSync();

    expect(
      source.contains("import 'dart:io'"),
      isFalse,
      reason: 'application layer must not import dart:io',
    );
    // Also catch the public-facing `dart:io` references that could leak in
    // even without the bare import.
    expect(
      RegExp(r'\bdart:io\b').hasMatch(source),
      isFalse,
      reason: 'application layer must not reference dart:io at all',
    );
  });
}

class FakeClock implements Clock {
  FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime nowUtc() => _now;
}

class FakePathProvider implements PathProviderPort {
  FakePathProvider(this.path);
  final String path;
  Object? errorToThrow;
  final List<String> calls = [];
  @override
  Future<String> getTemporaryPath() async {
    calls.add('getTemporaryPath');
    if (errorToThrow != null) throw errorToThrow!;
    return path;
  }
}

class FakeShareGateway implements ShareGateway {
  final List<List<ShareFile>> shared = [];
  final List<List<String>?> overrides = [];
  Object? errorToThrow;
  @override
  Future<void> shareFiles(
    List<ShareFile> files, {
    List<String>? fileNameOverrides,
  }) async {
    shared.add(files);
    overrides.add(fileNameOverrides);
    if (errorToThrow != null) throw errorToThrow!;
  }
}

class FakeFileWriter implements FileWriterPort {
  final List<String> writes = [];
  final Map<String, String> contents = {};
  final List<String> deletes = [];
  @override
  Future<void> writeString(String path, String contents) async {
    writes.add(path);
    this.contents[path] = contents;
  }

  @override
  Future<void> deleteIfExists(String path) async {
    deletes.add(path);
  }
}
