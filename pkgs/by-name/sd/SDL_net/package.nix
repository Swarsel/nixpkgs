{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  pkg-config,
  unstableGitUpdater,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_net";
  version = "1.2.8-unstable-2026-05-27";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_net";
    rev = "8363cd02baf1b65c287691bdd22c3dc87da9759d";
    hash = "sha256-sAZ9I7jOo33Btitcl8mn4R7fYn2W8GWPttXELeEq7h4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    SDL
    pkg-config
  ];

  propagatedBuildInputs = [
    SDL
  ];

  configureFlags = [
    (lib.enableFeature enableSdltest "sdltest")
  ];

  passthru.updateScript = unstableGitUpdater {
    branch = "SDL-1.2";
    tagFormat = "release-1.*";
    tagPrefix = "release-";
  };

  meta = {
    inherit (SDL.meta) platforms;
    description = "SDL networking library";
    homepage = "https://github.com/libsdl-org/SDL_net";
    license = lib.licenses.zlib;
    teams = [ lib.teams.sdl ];
  };
})
