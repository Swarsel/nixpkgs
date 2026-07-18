{
  lib,
  fetchurl,
  gitUpdater,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mate-common";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-common-${finalAttrs.version}.tar.xz";
    sha256 = "QrfCzuJo9x1+HBrU9pvNoOzWVXipZyIYfGt2N40mugo=";
  };

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-common";
  };

  meta = {
    description = "Common files for development of MATE packages";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
