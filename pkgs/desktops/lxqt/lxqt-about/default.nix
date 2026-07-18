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
  qtsvg,
  qttools,
  qtwayland,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-about";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-about";
    rev = version;
    hash = "sha256-wJ4KJ+gSj0sdlO1l68RzAaOM8HxdPP6S1gWCoRfRZ3c=";
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
    qtsvg
    qtwayland
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Dialogue window providing information about LXQt and the system it's running on";
    homepage = "https://github.com/lxqt/lxqt-about";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lxqt-about";
    teams = [ lib.teams.lxqt ];
  };
}
