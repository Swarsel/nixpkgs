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
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  sudo,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-sudo";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-sudo";
    rev = version;
    hash = "sha256-wPkIvm6U/dZvf3sE/IsWfK1D647DmVZPV/JZbsRl/HI=";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    kwindowsystem
    liblxqt
    libqtxdg
    qtbase
    qtsvg
    qtwayland
    sudo
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "GUI frontend for sudo/su";
    homepage = "https://github.com/lxqt/lxqt-sudo";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
}
