{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  gobject-introspection,
  gtk3,
  libayatana-appindicator,
  pkg-config,
  polkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-polkit";
  version = "1.28.1";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-polkit-${finalAttrs.version}.tar.xz";
    sha256 = "NQod0KjtaiycGDz/KiHzlCmelo/MauLoyTxWXa5gSug=";
  };

  nativeBuildInputs = [
    gobject-introspection
    gettext
    pkg-config
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    polkit
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-polkit";
  };

  meta = {
    description = "Integrates polkit authentication for MATE desktop";
    homepage = "https://mate-desktop.org";
    license = [ lib.licenses.gpl2Plus ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
