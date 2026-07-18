{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  kwindowsystem,
  liblxqt,
  libqtxdg,
  lxqt-build-tools,
  pkg-config,
  polkit,
  polkit-qt-1,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-policykit";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-policykit";
    rev = version;
    hash = "sha256-cMYBR0Uwc6v+s+F+uYbClbGh8BgovtxShgB62LX/WgU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    kwindowsystem
    liblxqt
    libqtxdg
    polkit
    polkit-qt-1
    qtbase
    qtsvg
    qtwayland
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "LXQt PolicyKit agent";
    homepage = "https://github.com/lxqt/lxqt-policykit";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lxqt-policykit-agent";
    teams = [ lib.teams.lxqt ];
  };
}
