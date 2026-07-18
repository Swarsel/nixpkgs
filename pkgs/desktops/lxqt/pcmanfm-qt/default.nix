{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  layer-shell-qt,
  libexif,
  libfm-qt,
  lxqt-build-tools,
  lxqt-menu-data,
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
  pname = "pcmanfm-qt";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "pcmanfm-qt";
    rev = version;
    hash = "sha256-KgYirooKoiUUkzEFsOScTZt/s1OTBLIjAYlW/Q0RQTk=";
  };

  postPatch = ''
    substituteInPlace config/pcmanfm-qt/lxqt/settings.conf.in --replace-fail @LXQT_SHARE_DIR@ /run/current-system/sw/share/lxqt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    layer-shell-qt
    libexif
    libfm-qt
    lxqt-menu-data
    menu-cache
    qtbase
    qtimageformats # add-on module to support more image file formats
    qtwayland
    qtsvg
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "File manager and desktop icon manager (Qt port of PCManFM and libfm)";
    homepage = "https://github.com/lxqt/pcmanfm-qt";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; unix;
    mainProgram = "pcmanfm-qt";
    teams = [ lib.teams.lxqt ];
  };
}
