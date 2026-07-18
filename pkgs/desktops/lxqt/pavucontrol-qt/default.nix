{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  libpulseaudio,
  lxqt-build-tools,
  pkg-config,
  qtbase,
  qtsvg,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "pavucontrol-qt";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "pavucontrol-qt";
    rev = version;
    hash = "sha256-Ja+9Tb88SxdvsJPiQadeziCgFtOnInTBSHcisNjrSpA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    libpulseaudio
    qtbase
    qtsvg
    qtwayland
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Pulseaudio mixer in Qt (port of pavucontrol)";
    homepage = "https://github.com/lxqt/pavucontrol-qt";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; linux;
    mainProgram = "pavucontrol-qt";
    teams = [ lib.teams.lxqt ];
  };
}
