/// Lightweight, platform-agnostic descriptor of a file chosen by the user
/// through the native file picker.
///
/// Mirrors the [ShareFile] pattern used by the share flow: the Domain
/// layer does not depend on `package:file_picker` or `package:cross_file`,
/// so the Application service can be tested with simple fakes.
typedef PickedBackupFile = ({String path, String name});

/// Port for opening the OS file picker scoped to a JSON backup file.
///
/// Implementations are responsible for filtering to the `.json` extension
/// and translating the plugin result into a [PickedBackupFile] record at
/// the Domain boundary.
abstract class FilePickerPort {
  /// Opens the native file picker filtered to `.json` files.
  ///
  /// Returns `null` when the user cancels the picker (the common case
  /// is no-op rather than an error).
  Future<PickedBackupFile?> pickJsonBackup();
}
