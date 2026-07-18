{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libqtxdg,
  lxqt-build-tools,
  qtbase,
  qtsvg,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "qtxdg-tools";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "qtxdg-tools";
    rev = version;
    hash = "sha256-pVFdodYoLQs8o8rF8etd7BKImgJRoDsckGg9DRrwVIY=";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    libqtxdg
    qtbase
    qtsvg
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "libqtxdg user tools";
    homepage = "https://github.com/lxqt/qtxdg-tools";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "qtxdg-mat";
    teams = [ lib.teams.lxqt ];
  };
}
