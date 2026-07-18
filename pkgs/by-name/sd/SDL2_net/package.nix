{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  pkg-config,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL2_net";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_net";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-FDJT5RPoquC527K0wG9IPouea6P3lwhHPqj29sZXMuw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    SDL2
    pkg-config
  ];

  propagatedBuildInputs = [ SDL2 ];

  configureFlags = [
    (lib.enableFeature false "examples") # can't find libSDL2_test.a
    (lib.enableFeature enableSdltest "sdltest")
  ];

  meta = {
    inherit (SDL2.meta) platforms;
    description = "SDL multiplatform networking library";
    homepage = "https://github.com/libsdl-org/SDL_net";
    license = lib.licenses.zlib;
    teams = [ lib.teams.sdl ];
  };
})
