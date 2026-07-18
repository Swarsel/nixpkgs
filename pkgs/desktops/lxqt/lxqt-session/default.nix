{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  kwindowsystem,
  layer-shell-qt,
  liblxqt,
  libpthread-stubs,
  libqtxdg,
  libxdmcp,
  lxqt-build-tools,
  pkg-config,
  procps,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  qtxdg-tools,
  wrapQtAppsHook,
  xdg-user-dirs,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-session";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-session";
    rev = version;
    hash = "sha256-CV0g553V4qxq9Cj/RUbr5jxESrrzFjAwR80NKhwNgDU=";
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
    layer-shell-qt
    libxdmcp
    liblxqt
    libpthread-stubs
    libqtxdg
    procps
    qtbase
    qtsvg
    qtwayland
    qtxdg-tools
    xdg-user-dirs
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Alternative session manager ported from the original razor-session";
    homepage = "https://github.com/lxqt/lxqt-session";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
}
