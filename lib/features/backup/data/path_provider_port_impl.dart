import 'package:path_provider/path_provider.dart';

import '../domain/ports/path_provider_port.dart';

/// Production [PathProviderPort] backed by the `path_provider` plugin.
///
/// This is the **only** place in the backup feature that imports
/// `package:path_provider`; the Domain and Application layers depend on
/// the abstract port instead.
class PathProviderPortImpl implements PathProviderPort {
  const PathProviderPortImpl();

  @override
  Future<String> getTemporaryPath() =>
      getTemporaryDirectory().then((d) => d.path);
}
