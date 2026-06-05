import '../domain/ports/file_picker_port.dart';
import '../domain/ports/file_reader_port.dart';

/// Thrown when the backup import flow fails for any user-visible reason.
///
/// Carries a [userMessage] safe to surface in a snackbar, plus the original
/// [cause] for logging. Callers should not let raw [cause] reach the UI.
/// Mirrors the [BackupShareException] pattern used by the share flow.
class BackupImportException implements Exception {
  BackupImportException(this.userMessage, {this.cause});

  /// User-facing message safe to render in a snackbar.
  final String userMessage;

  /// Original error that triggered this exception, or `null` if synthesized.
  final Object? cause;

  @override
  String toString() => 'BackupImportException: $userMessage';
}

/// Orchestrates the "import backup from file" flow.
///
/// Steps:
///   1. Ask [FilePickerPort] for a JSON file chosen by the user.
///   2. If the user cancels, resolve to `null` (no-op).
///   3. Otherwise read the file via [FileReaderPort].
///   4. Return the JSON content for the page to validate and replace data.
///
/// All non-cancellation failures are wrapped in [BackupImportException] so
/// the UI can show a single user-friendly message regardless of cause.
/// Symmetric to [BackupShareService].
class BackupImportService {
  BackupImportService({
    required this.filePicker,
    required this.fileReader,
  });

  final FilePickerPort filePicker;
  final FileReaderPort fileReader;

  bool _inFlight = false;

  /// True while a pick-and-read is in progress. The UI also disables the
  /// trigger; this guard exists as defense in depth against double-taps.
  bool get isInFlight => _inFlight;

  /// Runs the pick + read pipeline.
  ///
  /// Returns:
  ///   * `null` when the user cancels the file picker, or when another
  ///     import is already in flight (defense in depth).
  ///   * the JSON content of the selected file on success.
  ///
  /// Throws [BackupImportException] on any read or picker failure.
  Future<String?> pickAndRead() async {
    if (_inFlight) return null;
    _inFlight = true;
    try {
      final picked = await filePicker.pickJsonBackup();
      if (picked == null) return null;
      return await fileReader.readAsString(picked.path);
    } catch (e) {
      throw BackupImportException(
        'Could not read the selected backup file. Try again or paste the JSON manually.',
        cause: e,
      );
    } finally {
      _inFlight = false;
    }
  }
}
