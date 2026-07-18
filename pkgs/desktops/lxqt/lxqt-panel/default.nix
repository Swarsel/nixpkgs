{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  gitUpdater,
  kguiaddons,
  kwindowsystem,
  layer-shell-qt,
  libdbusmenu,
  libdbusmenu-lxqt,
  liblxqt,
  libpthread-stubs,
  libpulseaudio,
  libqtxdg,
  libstatgrab,
  libsysstat,
  libxdamage,
  libxdmcp,
  libxtst,
  lm_sensors,
  lxqt-build-tools,
  lxqt-globalkeys,
  lxqt-menu-data,
  pcre2,
  pkg-config,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  solid,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxqt-panel";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-panel";
    tag = finalAttrs.version;
    hash = "sha256-TExmFE02GDRWWHCzJNETSY5GbOXxxX1OFFrEe9krBqM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    libdbusmenu-lxqt
    kguiaddons
    kwindowsystem
    layer-shell-qt
    libxdamage
    libxdmcp
    libxtst
    libdbusmenu
    liblxqt
    libpthread-stubs
    libpulseaudio
    libqtxdg
    libstatgrab
    libsysstat
    lm_sensors
    lxqt-globalkeys
    lxqt-menu-data
    pcre2
    qtbase
    qtsvg
    qtwayland
    solid
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "LXQt desktop panel";
    homepage = "https://github.com/lxqt/lxqt-panel";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lxqt-panel";
    teams = [ lib.teams.lxqt ];
  };
})
