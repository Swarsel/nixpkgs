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
  pname = "qps";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "qps";
    rev = version;
    hash = "sha256-KH92JZkVLxz2iECF5z39yzAwt7TU2/WnJomPoAn8iDI=";
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
    description = "Qt based process manager";
    homepage = "https://github.com/lxqt/qps";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; linux; # does not build on darwin
    mainProgram = "qps";
    teams = [ lib.teams.lxqt ];
  };
}
