{
  lib,
  fetchFromGitHub,
  aquamarine,
  cairo,
  cmake,
  gcc15Stdenv,
  hyprgraphics,
  hyprlang,
  hyprtoolkit,
  hyprutils,
  hyprwire,
  libdrm,
  libqalculate,
  libxkbcommon,
  pixman,
  pkg-config,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprlauncher";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprlauncher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FHw6S2rz716ZwuF661aT5HYN1b6qyyBDkwhEL5hzHUk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    aquamarine
    cairo
    hyprgraphics
    hyprlang
    hyprtoolkit
    hyprutils
    hyprwire
    libdrm
    libqalculate
    libxkbcommon
    pixman
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "A multipurpose and versatile launcher / picker for Hyprland";
    license = lib.licenses.bsd3;
    platforms = with lib.platforms; linux ++ freebsd;
    mainProgram = "hyprlauncher";
    teams = [ lib.teams.hyprland ];
  };
})
