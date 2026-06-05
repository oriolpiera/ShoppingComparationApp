import 'dart:io';

import '../domain/ports/file_writer_port.dart';

/// Production [FileWriterPort] backed by `dart:io.File`.
///
/// This is the **only** place in the backup feature that imports
/// `dart:io`; the Application service depends on the abstract port.
class FileWriterPortImpl implements FileWriterPort {
  const FileWriterPortImpl();

  @override
  Future<void> writeString(String path, String contents) {
    return File(path).writeAsString(contents, flush: true);
  }

  @override
  Future<void> deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
