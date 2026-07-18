{
  lib,
  fetchurl,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk3,
  mate-menus,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mozo";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor version}/mozo-${version}.tar.xz";
    sha256 = "/piYT/1qqMNtBZS879ugPeObQtQeAHJRaAOE8870SSQ=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    glib
  ];

  propagatedBuildInputs = [
    mate-menus
    python3.pkgs.pygobject3
  ];

  doCheck = false;
  enableParallelBuilding = true;
  pyproject = false;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mozo";
  };

  meta = {
    description = "MATE Desktop menu editor";
    homepage = "https://github.com/mate-desktop/mozo";
    license = with lib.licenses; [ lgpl2Plus ];
    platforms = lib.platforms.unix;
    mainProgram = "mozo";
    teams = [ lib.teams.mate ];
  };
}
