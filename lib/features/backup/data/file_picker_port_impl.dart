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
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );

    if (file == null) return null;

    final path = file.path;
    if (path == null) return null;

    return (path: path, name: file.name);
  }
}
