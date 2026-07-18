{
  lib,
  common-updater-scripts,
  genericUpdater,
}:

{
  allowedVersions ? "",
  attrPath ? null,
  ignoredVersions ? "",
  odd-unstable ? false,
  patchlevel-unstable ? false,
  pname ? null,
  rev-prefix ? "",
  rev-suffix ? "",
  url ? null,
  version ? null,
}:

genericUpdater {
  inherit
    pname
    version
    attrPath
    allowedVersions
    ignoredVersions
    rev-prefix
    rev-suffix
    odd-unstable
    patchlevel-unstable
    ;

  versionLister = "${common-updater-scripts}/bin/list-archive-two-levels-versions ${
    lib.optionalString (url != null) "--url=${lib.escapeShellArg url}"
  }";
}
