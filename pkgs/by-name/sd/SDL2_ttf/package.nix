{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  freetype,
  harfbuzz,
  libGL,
  pkg-config,
  testers,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL2_ttf";
  version = "2.24.0";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-${finalAttrs.version}.tar.gz";
    hash = "sha256-Cyvx57ZWitvbybuSRkP3nZ3tr+Bh+h7Wh9HZrE5FO/0=";
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

  buildInputs = [
    SDL2
    freetype
    harfbuzz
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libGL
  ];

  configureFlags = [
    (lib.enableFeature false "harfbuzz-builtin")
    (lib.enableFeature false "freetype-builtin")
    (lib.enableFeature enableSdltest "sdltest")
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    inherit (SDL2.meta) platforms;
    description = "Support for TrueType (.ttf) font files with Simple Directmedia Layer";
    homepage = "https://github.com/libsdl-org/SDL_ttf";
    license = lib.licenses.zlib;
    pkgConfigModules = [ "SDL2_ttf" ];
    teams = [ lib.teams.sdl ];
  };
})
