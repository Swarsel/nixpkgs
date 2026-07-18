{
  lib,
  fetchFromGitHub,
  cmake,
  mkLibretroCore,
}:
mkLibretroCore {
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "swanstation";
    rev = "32e5654cb4ff17db3e950250a677767906fa3cf8";
    hash = "sha256-l4Vb1kSuoqMJC4gn+S61zuePZaYvJ/nmVyoFOlsCTBM=";
  };

  cmakeFlags = [
    "-DBUILD_LIBRETRO_CORE=ON"
  ];

  core = "swanstation";
  extraNativeBuildInputs = [ cmake ];
  makefile = "Makefile";

  meta = {
    description = "Port of SwanStation (a fork of DuckStation) to libretro";
    homepage = "https://github.com/libretro/swanstation";
    license = lib.licenses.gpl3Only;
  };
}
