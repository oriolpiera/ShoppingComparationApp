import '../domain/ports/clock.dart';
import '../domain/ports/file_writer_port.dart';
import '../domain/ports/path_provider_port.dart';
import '../domain/ports/share_gateway.dart';

/// Thrown when the backup share flow fails for any user-visible reason.
///
/// Carries a [userMessage] safe to surface in a snackbar, plus the original
/// [cause] for logging. Callers should not let raw [cause] reach the UI.
class BackupShareException implements Exception {
  BackupShareException(this.userMessage, {this.cause});

  /// User-facing message safe to render in a snackbar.
  final String userMessage;

  /// Original error that triggered this exception, or `null` if synthesized.
  final Object? cause;

  @override
  String toString() => 'BackupShareException: $userMessage';
}

/// Builds the default filename for a backup share.
///
/// Format: `shopping-backup-yyyyMMddTHHmmssZ.json` (compact ISO-8601, UTC,
/// ASCII-only, no colons — safe across Android, iOS, Windows, macOS, Linux).
String buildBackupFileName(DateTime nowUtc) {
  String two(int n) => n.toString().padLeft(2, '0');
  String four(int n) => n.toString().padLeft(4, '0');
  final stamp = '${four(nowUtc.year)}'
      '${two(nowUtc.month)}'
      '${two(nowUtc.day)}'
      'T'
      '${two(nowUtc.hour)}'
      '${two(nowUtc.minute)}'
      '${two(nowUtc.second)}'
      'Z';
  return 'shopping-backup-$stamp.json';
}

/// Orchestrates the "share backup as file" flow.
///
/// Steps:
///   1. Build a deterministic basename from the [Clock] (or use the
///      caller's [fileName] override when provided).
///   2. Resolve a staging directory via [PathProviderPort].
///   3. Write the JSON to that path via [FileWriterPort].
///   4. Hand the staged file to [ShareGateway] for the native share sheet.
///   5. Delete the staged file in `finally` (best effort).
///
/// All failures are wrapped in [BackupShareException] so the UI can show
/// a single user-friendly message regardless of the underlying cause.
class BackupShareService {
  BackupShareService({
    required this.clock,
    required this.pathProvider,
    required this.shareGateway,
    required this.fileWriter,
  });

  final Clock clock;
  final PathProviderPort pathProvider;
  final ShareGateway shareGateway;
  final FileWriterPort fileWriter;

  bool _inFlight = false;

  /// True while a share is in progress. The UI also disables the trigger;
  /// this guard exists as defense in depth against double-taps.
  bool get isInFlight => _inFlight;

  /// Stages [json] as a `.json` file in the temp directory and hands it to
  /// the share sheet.
  ///
  /// When [fileName] is supplied, it overrides the default timestamped
  /// basename (used by tests and by advanced callers that want a stable
  /// filename, e.g. "import-2026-06-05.json").
  Future<void> shareBackupJson(String json, {String? fileName}) async {
    if (_inFlight) return;
    _inFlight = true;
    final basename = fileName ?? buildBackupFileName(clock.nowUtc());
    String? stagedPath;
    try {
      final dir = await pathProvider.getTemporaryPath();
      stagedPath = '$dir/$basename';
      await fileWriter.writeString(stagedPath, json);
      await shareGateway.shareFiles(
        [(path: stagedPath, mimeType: 'application/json')],
        fileNameOverrides: [basename],
      );
    } catch (e) {
      throw BackupShareException(
        'Could not share the backup file. Try again or use Copy JSON.',
        cause: e,
      );
    } finally {
      _inFlight = false;
      if (stagedPath != null) {
        try {
          await fileWriter.deleteIfExists(stagedPath);
        } catch (_) {
          // Best-effort cleanup; never mask the original error.
        }
      }
    }
  }
}
