{
  lib,
  stdenv,
  fetchurl,
  dconf,
  gettext,
  gitUpdater,
  gtk3,
  isocodes,
  libstartup_notification,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-desktop";
  version = "1.28.2";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-desktop-${finalAttrs.version}.tar.xz";
    sha256 = "MrtLeSAUs5HB4biunBioK01EdlCYS0y6fSjpVWSWSqI=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    dconf
    isocodes
  ];

  propagatedBuildInputs = [
    gtk3
    libstartup_notification
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-desktop";
  };

  meta = {
    description = "Library with common API for various MATE modules";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.mate ];
  };
})
