{
  lib,
  stdenv,
  fetchurl,
  glib,
  libGL,
  libepoxy,
  libwpe,
  libx11,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation rec {
  pname = "wpebackend-fdo";
  version = "1.16.1";

  src = fetchurl {
    url = "https://wpewebkit.org/releases/wpebackend-fdo-${version}.tar.xz";
    sha256 = "sha256-VErhQBL45+QmuMtSLrCqqsgxrXw1YB0c8x03Zw4Ouzs=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wayland-scanner
  ];

  buildInputs = [
    wayland
    libepoxy
    glib
    libwpe
    libxkbcommon
    libGL
    libx11
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Freedesktop.org backend for WPE WebKit";
    homepage = "https://wpewebkit.org";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
