import 'package:pub_semver/pub_semver.dart';

import '../utils/app_logger.dart';

/// Mirrors utils/forceUpdate.ts in etia-user-app.
const String supportedRangeHeader = 'x-app-supported-range';

/// Returns true when [version] satisfies the semver [range].
/// Any unparsable input returns true (never block the app on a bad header),
/// same as the try/catch in the TS original.
bool isVersionSupported(String version, String range) {
  try {
    final trimmed = range.trim();
    if (trimmed.isEmpty) return true;
    final constraint = VersionConstraint.parse(trimmed);
    return constraint.allows(Version.parse(version));
  } catch (e) {
    AppLogger.warning('Ignoring bad force-update range "$range"', e);
    return true;
  }
}
