{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glfw3,
  kdePackages,
  libepoxy,
  libffi,
  libx11,
  libxau,
  libxcb,
  libxdmcp,
  pkg-config,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "wlay";
  version = "unstable-2022-01-26";

  src = fetchFromGitHub {
    owner = "atx";
    repo = "wlay";
    rev = "ed316060ac3ac122c0d3d8918293e19dfe9a6c90";
    hash = "sha256-Lu+EyoDHiXK9QzD4jdwbllCOCl2aEU+uK6/KxC2AUGQ=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    glfw3
    libx11
    libxau
    libxdmcp
    libepoxy
    libffi
    libxcb
    wayland
  ];

  meta = {
    inherit (wayland.meta) platforms;
    description = "Graphical output management for Wayland";
    homepage = "https://github.com/atx/wlay";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "wlay";
  };
}
