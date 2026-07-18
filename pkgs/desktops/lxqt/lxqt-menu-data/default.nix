{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  lxqt-build-tools,
  qttools,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-menu-data";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-menu-data";
    rev = version;
    hash = "sha256-Bu/M88VInCD6DzKFLjE3gZ5odJa0tvJ0EXHeLCBlgLw=";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Menu files for LXQt Panel, Configuration Center and PCManFM-Qt/libfm-qt";
    homepage = "https://github.com/lxqt/lxqt-menu-data";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
}
