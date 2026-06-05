/// Port for the tiny slice of file-system mutation the share service needs
/// (write the staged JSON, delete it after the share sheet closes).
///
/// Exists so the Application service stays free of `dart:io` — the Data
/// layer's `FileWriterPortImpl` is the only place that imports `dart:io`.
abstract class FileWriterPort {
  /// Writes [contents] to the file at [path], replacing any existing content.
  Future<void> writeString(String path, String contents);

  /// Deletes the file at [path] if it exists. Must not throw when the file
  /// is missing; cleanup is best-effort.
  Future<void> deleteIfExists(String path);
}
