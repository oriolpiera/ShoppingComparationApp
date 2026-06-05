/// Port for a writable, platform-agnostic location where the share service
/// can stage the backup JSON before handing it to the share sheet.
///
/// Domain layer does not import `package:path_provider` directly; the
/// production implementation lives in the Data layer.
abstract class PathProviderPort {
  /// Returns a directory path suitable for staging short-lived files.
  Future<String> getTemporaryPath();
}
