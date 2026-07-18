{
  lib,
  common-updater-scripts,
  genericUpdater,
}:

{
  allowedVersions ? "",
  attrPath ? null,
  extraRegex ? null,
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

  versionLister = "${common-updater-scripts}/bin/list-directory-versions ${
    lib.optionalString (url != null) "--url=${lib.escapeShellArg url}"
  } ${lib.optionalString (extraRegex != null) "--extra-regex=${lib.escapeShellArg extraRegex}"}";
}
