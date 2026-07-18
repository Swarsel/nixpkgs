{
  lib,
  stdenv,
  fetchurl,
  SDL,
  autoreconfHook,
  fetchpatch,
  pango,
  pkg-config,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_Pango";
  version = "0.1.2";

  src = fetchurl {
    url = "mirror://sourceforge/sdlpango/SDL_Pango-${finalAttrs.version}.tar.gz";
    hash = "sha256-f3XTuXrPcHxpbqEmQkkGIE6/oHZgFi3pJRc83QJX66Q=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-jfr+R4tIVZfYoaY4i+aNSGLwJGEipnuKqD2O9orP5QI=";
      name = "0000-api_additions.patch";
      url = "https://sources.debian.org/data/main/s/sdlpango/0.1.2-6/debian/patches/api_additions.patch";
    })
    ./0001-fixes.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    SDL
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    SDL
    pango
  ];

  configureFlags = [
    (lib.enableFeature enableSdltest "sdltest")
  ];

  meta = {
    inherit (SDL.meta) platforms;
    description = "Connects the Pango rendering engine to SDL";
    homepage = "https://sdlpango.sourceforge.net/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ puckipedia ];
    teams = [ lib.teams.sdl ];
  };
})
