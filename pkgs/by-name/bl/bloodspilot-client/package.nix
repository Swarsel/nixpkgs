{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  SDL_ttf,
  expat,
  libGL,
  libGLU,
  libx11,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bloodspilot-client";
  version = "1.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/bloodspilot/client-sdl/v${finalAttrs.version}/bloodspilot-client-sdl-${finalAttrs.version}.tar.gz";
    hash = "sha256-svOVg8b33cUpsesd9Xq8PRHvnZFKnxoA/cKqslVJlOM=";
  };

  patches = [ ./bloodspilot-sdl-window-fix.patch ];

  buildInputs = [
    libx11
    SDL
    SDL_ttf
    SDL_image
    libGLU
    libGL
    expat
    zlib
  ];

  env.NIX_LDFLAGS = "-lX11";

  meta = {
    description = "Multiplayer space combat game (client part)";
    homepage = "http://bloodspilot.sf.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "bloodspilot-client-sdl";
  };
})
