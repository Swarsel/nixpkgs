{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libpthread-stubs,
  libsm,
  libxdmcp,
  lxqt-build-tools,
  openbox,
  pcre,
  pkg-config,
  qtbase,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "obconf-qt";
  version = "0.16.6";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "obconf-qt";
    rev = version;
    hash = "sha256-Qd8vIfYjY/etv2IXEqQQM1ni0eS6Vuk/MnqtuLh4Mow=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    libsm
    libxdmcp
    libpthread-stubs
    openbox
    pcre
    qtbase
    qtwayland
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Qt port of obconf, the Openbox configuration tool";
    homepage = "https://github.com/lxqt/obconf-qt";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "obconf-qt";
    teams = [ lib.teams.lxqt ];
  };
}
