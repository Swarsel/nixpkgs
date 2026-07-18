{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  nix-update-script,
}:

# As of 2025-06-27 this library has no dependents in nixpkgs (https://github.com/NixOS/nixpkgs/pull/420339) and is
# considered for deletion.
stdenv.mkDerivation (finalAttrs: {
  pname = "SDL2_sound";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "icculus";
    repo = "SDL_sound";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Q2q6gp6nOCtAxRb0keX5hikyPGYhUcqBhEosEZiWlWg=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ SDL2 ];

  cmakeFlags = [
    (lib.cmakeBool "SDLSOUND_DECODER_MIDI" true)
    (lib.cmakeBool "SDLSOUND_BUILD_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "SDLSOUND_BUILD_STATIC" stdenv.hostPlatform.isStatic)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SDL2 sound library";
    homepage = "https://www.icculus.org/SDL_sound/";

    license = with lib.licenses; [
      zlib

      # various vendored decoders
      publicDomain

      # timidity
      artistic1
      lgpl21Only
    ];

    platforms = lib.platforms.all;
    mainProgram = "playsound";
    teams = [ lib.teams.sdl ];
  };
})
