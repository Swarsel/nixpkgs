{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  freetype,
  unstableGitUpdater,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_ttf";
  version = "2.0.11-unstable-2026-07-05";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_ttf";
    rev = "3af6dd26174bb719c241447d1ea55e40597bb9a6";
    hash = "sha256-OLPsLIddOnKpMjW+P9D1gEKyYC125X6sqpBbm44d8d8=";
  };

  strictDeps = true;

  buildInputs = [
    SDL
    freetype
  ];

  configureFlags = [
    (lib.enableFeature enableSdltest "sdltest")
  ];

  env.FT2_CONFIG = lib.getExe' freetype.dev "freetype-config";
  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-liconv";
  # pass in correct *-config for cross builds
  env.SDL_CONFIG = lib.getExe' (lib.getDev SDL) "sdl-config";

  passthru.updateScript = unstableGitUpdater {
    branch = "SDL-1.2";
    tagFormat = "release-2.0.11";
    tagPrefix = "release-";
  };

  meta = {
    inherit (SDL.meta) platforms;
    description = "SDL TrueType library";
    homepage = "https://github.com/libsdl-org/SDL_ttf";
    license = lib.licenses.zlib;

    knownVulnerabilities = [
      # CVE applies to SDL2 https://github.com/NixOS/nixpkgs/pull/274836#issuecomment-2708627901
      # "CVE-2022-27470"
    ];

    teams = [ lib.teams.sdl ];
  };
})
