{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  freealut,
  libGL,
  libGLU,
  libvorbis,
  openal,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ultimate-stunts";
  version = "0.7.7.1";

  src = fetchurl {
    url = "mirror://sourceforge/ultimatestunts/ultimatestunts-srcdata-${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }.tar.gz";

    sha256 = "sha256-/MBuSi/yxcG9k3ZwrNsHkUDzzg798AV462VZog67JtM=";
  };

  postPatch = ''
    sed -e '1i#include <unistd.h>' -i $(find . -name '*.c' -o -name '*.cpp')
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    SDL
    libGLU
    libGL
    SDL_image
    freealut
    openal
    libvorbis
  ];

  meta = {
    description = "Remake of the popular racing DOS-game Stunts";
    homepage = "https://www.ultimatestunts.nl/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
  };
})
