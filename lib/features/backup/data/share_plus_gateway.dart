import 'package:share_plus/share_plus.dart';

import '../domain/ports/share_gateway.dart';

/// Production [ShareGateway] backed by `share_plus`.
///
/// Maps the Domain-layer [ShareFile] record to `XFile` (a `cross_file` type
/// re-exported by `share_plus`) and invokes the native share sheet.
class SharePlusGateway implements ShareGateway {
  const SharePlusGateway();

  @override
  Future<void> shareFiles(
    List<ShareFile> files, {
    List<String>? fileNameOverrides,
  }) async {
    final xfiles = files
        .map((f) => XFile(f.path, mimeType: f.mimeType))
        .toList(growable: false);

    // TODO(iOS): pass sharePositionOrigin when the iOS folder lands.
    // share_plus on iPad requires a Rect to anchor the popover. Today's
    // build does not include an iOS folder; track as a follow-up.
    await SharePlus.instance.share(
      ShareParams(
        files: xfiles,
        fileNameOverrides: fileNameOverrides,
      ),
    );
  }
}
