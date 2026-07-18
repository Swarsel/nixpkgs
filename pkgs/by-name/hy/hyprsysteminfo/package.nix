{
  lib,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gcc15Stdenv,
  hyprland-qt-support,
  hyprutils,
  pciutils,
  pkg-config,
  qt6,
}:
let
  inherit (lib.strings) makeBinPath;
in
gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprsysteminfo";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprsysteminfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KDxT9B+1SATWiZdUBAQvZu17vk3xmyXcw2Zy56bdWbY=";
  };

  patches = [
    # Fix Qt6::WaylandClientPrivate not found
    # https://github.com/hyprwm/hyprsysteminfo/pull/21
    (fetchpatch {
      hash = "sha256-rfKyV0gkfXEhTcPHlAB+yxZ+92umBV22YOK9aLMMBhM=";
      url = "https://github.com/hyprwm/hyprsysteminfo/commit/fe81610278676d26ff47f62770ac238220285d3a.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtwayland
    hyprutils
    hyprland-qt-support
  ];

  preFixup = ''
    qtWrapperArgs+=(--prefix PATH : "${makeBinPath [ pciutils ]}")
  '';

  meta = {
    description = "Tiny qt6/qml application to display information about the running system";
    homepage = "https://github.com/hyprwm/hyprsysteminfo";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "hyprsysteminfo";
    teams = [ lib.teams.hyprland ];
  };
})
