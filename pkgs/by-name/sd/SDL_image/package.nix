{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  giflib,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  libxpm,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_image";
  version = "1.2.12-unstable-2026-07-05";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_image";
    rev = "2ffb2e3e1eba037897164e3ac6c67570d8bccd79";
    hash = "sha256-fGwSb3GYfzcrWn7F70xhNxBXygYdD2uuzFQudS1lCqU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    SDL
    pkg-config
  ];

  buildInputs = [
    SDL
    giflib
    libxpm
    libjpeg
    libpng
    libtiff
    libwebp
  ];

  configureFlags = [
    # Disable dynamic loading or else dlopen will fail because of no proper
    # rpath
    (lib.enableFeature false "jpg-shared")
    (lib.enableFeature false "png-shared")
    (lib.enableFeature false "tif-shared")
    (lib.enableFeature false "webp-shared")
    (lib.enableFeature (!stdenv.hostPlatform.isDarwin) "sdltest")
  ];

  passthru.updateScript = unstableGitUpdater {
    branch = "SDL-1.2";
    tagFormat = "release-1.*";
    tagPrefix = "release-";
  };

  meta = {
    inherit (SDL.meta) platforms;
    description = "SDL image library";
    homepage = "http://www.libsdl.org/projects/SDL_image/";
    license = lib.licenses.zlib;
    teams = [ lib.teams.sdl ];
  };
})
