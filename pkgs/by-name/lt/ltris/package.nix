{
  lib,
  stdenv,
  fetchurl,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  directoryListingUpdater,
  sdl2-compat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ltris";
  version = "2.0.4";

  src = fetchurl {
    url = "mirror://sourceforge/lgames/ltris2-${finalAttrs.version}.tar.gz";
    hash = "sha256-SCFQSV+dh7sTnVrxq+xwMDg8N/2z51pF6brWfq15jto=";
  };

  buildInputs = [
    sdl2-compat
    SDL2_mixer
    SDL2_image
    SDL2_ttf
  ];

  hardeningDisable = [ "format" ];

  passthru.updateScript = directoryListingUpdater {
    inherit (finalAttrs) version;
    pname = "ltris2";
    extraRegex = "(?!.*-win(32|64)).*";
    url = "https://lgames.sourceforge.io/LTris/";
  };

  meta = {
    description = "Tetris clone from the LGames series";
    homepage = "https://lgames.sourceforge.io/LTris/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ marcin-serwin ];
    platforms = lib.platforms.all;
    mainProgram = "ltris2";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
