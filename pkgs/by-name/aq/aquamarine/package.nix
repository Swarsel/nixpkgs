{
  lib,
  fetchFromGitHub,
  cmake,
  gcc15Stdenv,
  hwdata,
  hyprutils,
  hyprwayland-scanner,
  libGL,
  libdisplay-info,
  libdrm,
  libffi,
  libgbm,
  libinput,
  nix-update-script,
  pixman,
  pkg-config,
  seatd,
  udev,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "aquamarine";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "aquamarine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cUQENbJn0PHQUttXame5+PbGGew+BckHZFTfpb8XGI8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    hyprwayland-scanner
    pkg-config
  ];

  buildInputs = [
    hwdata
    hyprutils
    libdisplay-info
    libdrm
    libffi
    libGL
    libinput
    libgbm
    pixman
    seatd
    udev
    wayland
    wayland-protocols
    wayland-scanner
  ];

  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Very light linux rendering backend library";
    homepage = "https://github.com/hyprwm/aquamarine";
    changelog = "https://github.com/hyprwm/aquamarine/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    teams = [ lib.teams.hyprland ];
  };
})
