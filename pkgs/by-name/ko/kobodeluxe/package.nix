{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  libGL,
  libGLU,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kobodeluxe";
  version = "0.5.1";

  src = fetchurl {
    url = "https://olofson.net/kobodl/download/KoboDeluxe-${finalAttrs.version}.tar.bz2";
    sha256 = "0f7b910a399d985437564af8c5d81d6dcf22b96b26b01488d72baa6a6fdb5c2c";
  };

  patches = [ ./glibc29.patch ];

  buildInputs = [
    SDL
    SDL_image
    libGLU
    libGL
  ];

  prePatch = ''
    sed -e 's/char \*tok/const char \*tok/' -i graphics/window.cpp
  '';

  meta = {
    description = "Enhanced version of Akira Higuchi's game XKobo  for Un*x systems with X11";
    homepage = "https://olofson.net/kobodl/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "kobodl";
  };
})
