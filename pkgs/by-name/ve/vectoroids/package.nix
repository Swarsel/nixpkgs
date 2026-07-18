{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  SDL2_image,
  SDL2_mixer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vectoroids";
  version = "1.1.2";

  src = fetchurl {
    url = "https://tuxpaint.org/ftp/unix/x/vectoroids/src/vectoroids-${finalAttrs.version}.tar.gz";
    hash = "sha256-aLV4rrNuLKODYGD+0UBAQeQKKCNlFOX2g5CcjjkCWyQ=";
  };

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
  ];

  preConfigure = ''
    sed -i s,/usr/local,$out, Makefile
    mkdir -p $out/bin
  '';

  meta = {
    inherit (SDL2.meta) platforms;
    description = "Clone of the classic arcade game Asteroids by Atari";
    homepage = "http://www.newbreedsoftware.com/vectoroids/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "vectoroids";
  };
})
