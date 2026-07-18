{
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  kdePackages,
  mkDerivation,
  pkg-config,
  qtbase,
  qtx11extras,
  wayland,
  wayland-scanner,
}:

mkDerivation {
  pname = "kguiaddons";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    extra-cmake-modules
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland-scanner
  ];

  buildInputs = [
    qtx11extras
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    kdePackages.plasma-wayland-protocols
  ];

  propagatedBuildInputs = [ qtbase ];
  meta.homepage = "https://invent.kde.org/frameworks/kguiaddons";
}
