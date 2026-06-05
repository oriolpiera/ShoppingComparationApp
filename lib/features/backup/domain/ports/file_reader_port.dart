/// Port for the tiny slice of file-system read access the import service
/// needs (read the picked JSON).
///
/// Exists so the Application service stays free of `dart:io` — the Data
/// layer's `FileReaderPortImpl` is the only place that imports `dart:io`.
/// Symmetric to [FileWriterPort] used by the share flow.
abstract class FileReaderPort {
  /// Reads the file at [path] and returns its contents as a UTF-8 string.
  ///
  /// Throws [FileSystemException] (or a subtype) when the file cannot be
  /// opened, read, or decoded. The Application service wraps those into
  /// a [BackupImportException] for the UI layer.
  Future<String> readAsString(String path);
}
