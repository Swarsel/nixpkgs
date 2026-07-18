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
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-globalkeys";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-globalkeys";
    rev = version;
    hash = "sha256-VhySpJYHdi17U4yJBWXEWE2KEyG7AVcWYLpYXr2iCyc=";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    kwindowsystem
    liblxqt
    libqtxdg
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "LXQt service for global keyboard shortcuts registration";
    homepage = "https://github.com/lxqt/lxqt-globalkeys";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
}
