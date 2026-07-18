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
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-openssh-askpass";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-openssh-askpass";
    rev = version;
    hash = "sha256-87soVKVcC3B6Wm7iRy15k/rjLb9OX/2se0btIOyKA6Q=";
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
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "GUI to query passwords on behalf of SSH agents";
    homepage = "https://github.com/lxqt/lxqt-openssh-askpass";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lxqt-openssh-askpass";
    teams = [ lib.teams.lxqt ];
  };
}
