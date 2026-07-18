{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libexif,
  libfm-qt,
  libpthread-stubs,
  libxdmcp,
  lxqt-build-tools,
  menu-cache,
  pkg-config,
  qtbase,
  qtimageformats,
  qtsvg,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lximage-qt";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lximage-qt";
    rev = version;
    hash = "sha256-ThP7MuAKysJ/Q/JSO12CuwCt6mCU5tZ2DiKEO0Nfg3U=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    libxdmcp
    libexif
    libfm-qt
    libpthread-stubs
    menu-cache
    qtbase
    qtimageformats # add-on module to support more image file formats
    qtsvg
    qtwayland
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Image viewer and screenshot tool for lxqt";
    homepage = "https://github.com/lxqt/lximage-qt";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; unix;
    mainProgram = "lximage-qt";
    teams = [ lib.teams.lxqt ];
  };
}
