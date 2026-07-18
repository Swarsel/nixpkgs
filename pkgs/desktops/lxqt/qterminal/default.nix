{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  layer-shell-qt,
  lxqt-build-tools,
  nixosTests,
  qtbase,
  qtermwidget,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "qterminal";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "qterminal";
    rev = version;
    hash = "sha256-8Bp4ZZ/oi4p6pAo/vRAmeSu0tfWZBvTBZTrm4ppJwFU=";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    layer-shell-qt
    qtbase
    qtermwidget
    qtwayland
  ];

  passthru.tests.test = nixosTests.terminal-emulators.qterminal;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Lightweight Qt-based terminal emulator";
    homepage = "https://github.com/lxqt/qterminal";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; unix;
    mainProgram = "qterminal";
    teams = [ lib.teams.lxqt ];
  };
}
