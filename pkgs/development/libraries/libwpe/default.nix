{
  lib,
  stdenv,
  fetchurl,
  libGL,
  libx11,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libwpe";
  version = "1.16.3";

  src = fetchurl {
    url = "https://wpewebkit.org/releases/libwpe-${version}.tar.xz";
    sha256 = "sha256-yID6jWB7Kqbq3efW1jArE5brw4No/iMy+iDhk8fuFCA=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    libxkbcommon
    libGL
    libx11
  ];

  meta = {
    description = "General-purpose library for WPE WebKit";
    homepage = "https://wpewebkit.org";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
