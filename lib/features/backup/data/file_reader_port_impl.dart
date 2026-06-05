import 'dart:io';

import '../domain/ports/file_reader_port.dart';

/// Production [FileReaderPort] backed by `dart:io.File`.
///
/// This is the **only** place in the backup feature that imports
/// `dart:io` for reads; the Application service depends on the abstract
/// port. Symmetric to `FileWriterPortImpl` used by the share flow.
class FileReaderPortImpl implements FileReaderPort {
  const FileReaderPortImpl();

  @override
  Future<String> readAsString(String path) {
    return File(path).readAsString();
  }
}
