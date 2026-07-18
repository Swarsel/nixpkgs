{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  json-glib,
  libexif,
  libfm-qt,
  lxqt-build-tools,
  menu-cache,
  pkg-config,
  qtbase,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-archiver";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-archiver";
    rev = version;
    hash = "sha256-f8s29INIJeqmPr6BWqQxYWWkjbG1wy+bUYZSy2OECKg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    json-glib
    libexif
    libfm-qt
    menu-cache
    qtbase
    qtwayland
  ];

  hardeningDisable = [ "format" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Archive tool for the LXQt desktop environment";
    homepage = "https://github.com/lxqt/lxqt-archiver/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jchw ];
    platforms = with lib.platforms; unix;
    mainProgram = "lxqt-archiver";
    teams = [ lib.teams.lxqt ];
  };
}
