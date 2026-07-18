{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cmake,
  gitUpdater,
  kwindowsystem,
  layer-shell-qt,
  libpthread-stubs,
  libqtxdg,
  libxdmcp,
  lxqt-build-tools,
  perl,
  pkg-config,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "screengrab";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "screengrab";
    tag = finalAttrs.version;
    hash = "sha256-WgQWFNAu+cws442o1HubuaANsg0Hxg0XLyZ/CeA3abM=";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    pkg-config
    perl # needed by LXQtTranslateDesktop.cmake
    qttools
    autoPatchelfHook # fix libuploader.so and libextedit.so not found
    wrapQtAppsHook
  ];

  buildInputs = [
    kwindowsystem
    layer-shell-qt
    libxdmcp
    libpthread-stubs
    libqtxdg
    qtbase
    qtsvg
    qtwayland
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Crossplatform tool for fast making screenshots";
    homepage = "https://github.com/lxqt/screengrab";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "screengrab";
    teams = [ lib.teams.lxqt ];
  };
})
