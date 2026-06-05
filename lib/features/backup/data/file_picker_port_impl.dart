import 'package:file_picker/file_picker.dart';

import '../domain/ports/file_picker_port.dart';

/// Production [FilePickerPort] backed by `package:file_picker`.
///
/// This is the **only** place in the backup feature that imports
/// `package:file_picker`; the Domain and Application layers depend on
/// the abstract port instead.
///
/// Mirrors the `SharePlusGateway` pattern used by the share flow.
class FilePickerPortImpl implements FilePickerPort {
  const FilePickerPortImpl();

  @override
  Future<PickedBackupFile?> pickJsonBackup() async {
    // Use `FileType.any` so the OS file picker shows every file the user
    // has access to (Downloads, Google Drive, etc.), regardless of the
    // MIME type the source registers. Android SAF filters by MIME, and
    // many cloud providers don't tag `.json` files as `application/json`,
    // which caused the picker to look empty.
    //
    // Backup-content validation is delegated downstream: the import
    // service / repository parse the file as JSON and surface a friendly
    // "Invalid backup file" snackbar if the content is not a recognized
    // backup payload.
    final file = await FilePicker.pickFile(type: FileType.any);

    if (file == null) return null;

    final path = file.path;
    if (path == null) return null;

    return (path: path, name: file.name);
  }
}
