/// Lightweight, platform-agnostic descriptor of a file to share.
///
/// We intentionally do **not** leak `package:cross_file`'s `XFile` into the
/// Domain layer: `XFile` is a plugin-shaped type that would couple the
/// contract to `share_plus`. The Data-layer `SharePlusGateway` maps
/// `ShareFile` to `XFile` at the boundary.
typedef ShareFile = ({String path, String mimeType});

/// Port for presenting the native share sheet.
///
/// Implementations are responsible for mapping [ShareFile] records to whatever
/// the underlying plugin (e.g. `share_plus`) expects, and for honoring the
/// optional positional [fileNameOverrides] list.
abstract class ShareGateway {
  /// Present the native share sheet. Resolves when the user dismisses it.
  ///
  /// [fileNameOverrides] is applied positionally and must align 1:1 with
  /// [files] (same length, same order). When `null`, the underlying plugin
  /// uses each file's basename.
  Future<void> shareFiles(
    List<ShareFile> files, {
    List<String>? fileNameOverrides,
  });
}
