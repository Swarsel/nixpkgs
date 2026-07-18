{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  fetchFromGitLab,
  callPackage,
  capstone,
  cmake,
  coreutils,
  curl,
  dbus,
  freetype,
  glfw,
  gtk3,
  html-tidy,
  libffi,
  libglvnd,
  libxkbcommon,
  md4c,
  nativefiledialog-extended,
  ninja,
  nlohmann_json,
  onetbb,
  pkg-config,
  pugixml,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zstd,
  withGtkFileSelector ? false,
  withWayland ? stdenv.hostPlatform.isLinux,
}:

(import ./package-versions.nix {
  inherit
    lib
    stdenv
    fetchFromGitHub
    fetchFromGitLab
    fetchurl
    callPackage

    coreutils
    cmake
    ninja
    pkg-config
    wayland-scanner

    capstone
    dbus
    freetype
    glfw
    onetbb

    withGtkFileSelector
    gtk3

    withWayland
    libglvnd
    libxkbcommon
    wayland
    wayland-protocols
    libffi

    md4c
    pugixml
    curl
    zstd
    nlohmann_json
    nativefiledialog-extended
    html-tidy
    ;
}).tracy_latest
