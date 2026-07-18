{
  lib,
  fetchFromGitHub,
  aquamarine,
  cairo,
  cmake,
  gcc15Stdenv,
  gtest,
  hyprgraphics,
  hyprlang,
  hyprutils,
  hyprwayland-scanner,
  iniparser,
  libGL,
  libdrm,
  libgbm,
  libxkbcommon,
  pango,
  pixman,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprtoolkit";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprtoolkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gJSBj4Pd4e9nERAKo/qiHqDMpS2hBfyOI0uGCbbiML4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    hyprwayland-scanner
    wayland-scanner
  ];

  buildInputs = [
    aquamarine
    cairo
    gtest
    hyprgraphics
    hyprlang
    hyprutils
    iniparser
    libdrm
    libgbm
    libGL
    libxkbcommon
    pango
    pixman
    wayland
    wayland-protocols
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "A modern C++ Wayland-native GUI toolkit";
    license = lib.licenses.bsd3;
    platforms = with lib.platforms; linux ++ freebsd;
    teams = [ lib.teams.hyprland ];
  };
})
