{
  lib,
  stdenv,
  fetchurl,
  SDL,
  flac,
  libmikmod,
  libvorbis,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_sound";
  version = "1.0.3";

  src = fetchurl {
    url = "https://icculus.org/SDL_sound/downloads/SDL_sound-${finalAttrs.version}.tar.gz";
    hash = "sha256-OZn9C7tIUomlK+FLL2i1ccuE44DMQzh+rfd49kx55t8=";
  };

  strictDeps = true;

  buildInputs = [
    SDL
    flac
    libmikmod
    libvorbis
  ];

  configureFlags = [
    (lib.enableFeature enableSdltest "sdltest")
  ];

  env.SDL_CONFIG = lib.getExe' (lib.getDev SDL) "sdl-config";

  meta = {
    inherit (SDL.meta) platforms;
    description = "SDL sound library";
    homepage = "https://www.icculus.org/SDL_sound/";
    license = lib.licenses.lgpl21Plus;
    mainProgram = "playsound";
    teams = [ lib.teams.sdl ];
  };
})
