{
  lib,
  stdenv,
  fetchurl,
  SDL,
  boost,
  cmake,
  eigen2,
  libGL,
  libGLU,
  lua5_1,
  luabind,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "soi";
  version = "0.1.2";

  src = fetchurl {
    url = "mirror://sourceforge/project/soi/Spheres%20of%20Influence-${finalAttrs.version}-Source.tar.bz2";
    sha256 = "03c3wnvhd42qh8mi68lybf8nv6wzlm1nx16d6pdcn2jzgx1j2lzd";
    name = "soi-${finalAttrs.version}.tar.bz2";
  };

  # CMake 2.6 is deprecated and is no longer supported by CMake > 4
  # https://github.com/NixOS/nixpkgs/issues/445447
  patches = [ ./cmake-4-build.patch ];
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    lua5_1
    luabind
    libGLU
    libGL
    SDL
  ];

  cmakeFlags = [
    "-DEIGEN_INCLUDE_DIR=${eigen2}/include/eigen2"
    "-DLUABIND_LIBRARY=${luabind}/lib/libluabind09.a"
  ];

  meta = {
    description = "Physics-based puzzle game";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "soi";
    downloadPage = "https://sourceforge.net/projects/soi/files/";
  };
})
