{
  lib,
  stdenv,
  fetchurl,
  SDL,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_stretch";
  version = "0.3.1";

  src = fetchurl {
    url = "mirror://sourceforge/sdl-stretch/${finalAttrs.version}/SDL_stretch-${finalAttrs.version}.tar.bz2";
    hash = "sha256-fL8L+rAMPt1uceGH0qLEgncEh4DiySQIuqt7YjUy/Nc=";
  };

  strictDeps = true;
  nativeBuildInputs = [ SDL ];
  buildInputs = [ SDL ];

  configureFlags = [
    (lib.enableFeature (!stdenv.hostPlatform.isDarwin) "sdltest")
  ];

  meta = {
    inherit (SDL.meta) platforms;
    description = "Stretch Functions For SDL";
    homepage = "https://sdl-stretch.sourceforge.net/";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
    # sdlstretchcode.c:38:10: fatal error: 'malloc.h' file not found
    broken = stdenv.hostPlatform.isDarwin;
  };
})
