{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_mixer,
  fetchpatch,
  libintl,
  libpng,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lbreakout2";
  version = "2.6.5";

  src = fetchurl {
    url = "mirror://sourceforge/lgames/lbreakout2-${finalAttrs.version}.tar.gz";
    hash = "sha256-kQTWF1VT2jRC3GpfxAemaeL1r/Pu3F0wQJ6wA7enjW8=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-ycsuxfokpOblLky42MwtJowdEp7v5dZRMFIR4id4ZBI=";
      url = "https://sources.debian.org/data/main/l/lbreakout2/2.6.5-2/debian/patches/sdl_fix_pauses.patch";
    })
  ];

  buildInputs = [
    SDL
    SDL_mixer
    libintl
    libpng
    zlib
  ];

  configureFlags = [
    (lib.enableFeature (!stdenv.hostPlatform.isDarwin) "sdltest")
  ];

  # With fortify it crashes at runtime:
  #   *** buffer overflow detected ***: terminated
  #   Aborted (core dumped)
  hardeningDisable = [ "fortify" ];

  meta = {
    description = "Breakout clone from the LGames series";
    homepage = "http://lgames.sourceforge.net/LBreakout2/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lbreakout2";
    hydraPlatforms = lib.platforms.linux; # build hangs on both Darwin platforms, needs investigation
  };
})
