{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  SDL_mixer,
  SDL_net,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gav";
  version = "0.9.0";

  src = fetchurl {
    url = "mirror://sourceforge/gav/gav-${finalAttrs.version}.tar.gz";
    sha256 = "8f0deb8b2cd775b339229054f4f282583a4cfbcba9d27a6213cf910bab944f3e";
  };

  patches = [ ./gcc.patch ];

  buildInputs = [
    SDL
    SDL_image
    SDL_mixer
    SDL_net
  ];

  prePatch = ''
    mkdir -p $out/bin
    sed -e "s@/usr@$out@" -i Makefile
    sed -e "s@/usr@$out@" -i Theme.h
  '';

  meta = {
    description = "Remake of AV Arcade Volleyball";
    homepage = "https://gav.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gav";
  };
})
