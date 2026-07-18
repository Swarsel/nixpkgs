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
  # an explicit url is needed when src.meta.homepage or src.url don't
  # point to a git repo (eg. when using fetchurl, fetchzip, ...)
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

  versionLister = "${common-updater-scripts}/bin/list-git-tags ${
    lib.optionalString (url != null) "--url=${url}"
  }";
}
