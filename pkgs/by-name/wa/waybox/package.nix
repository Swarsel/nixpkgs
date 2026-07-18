{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libGL,
  libevdev,
  libgbm,
  libinput,
  libxkbcommon,
  libxml2,
  meson,
  ninja,
  pixman,
  pkg-config,
  udev,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waybox";
  version = "0.2.2-unstable-2026-01-03"; # To remove dependency on wlroots_0_17, switch to stable in next release

  src = fetchFromGitHub {
    owner = "wizbright";
    repo = "waybox";
    rev = "044ce8f7c05720a319984eb569ee713923637940";
    hash = "sha256-xrjOZzexQSPTKsQstMa0/UYX5A70N5zkO3NIBDnEy68=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libGL
    libxkbcommon
    libxml2
    libevdev
    libinput
    libgbm
    pixman
    udev
    wayland
    wayland-protocols
    wlroots_0_19
  ];

  depsBuildBuild = [
    pkg-config
  ];

  dontUseCmakeConfigure = true;
  passthru.providedSessions = [ "waybox" ];

  meta = {
    inherit (wayland.meta) platforms;
    description = "Openbox clone on Wayland";
    homepage = "https://github.com/wizbright/waybox";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "waybox";
  };
})
