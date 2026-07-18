{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  directoryListingUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lpairs2";
  version = "2.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/lgames/lpairs2-${finalAttrs.version}.tar.gz";
    hash = "sha256-y4eRLWhfI4XMBtGCqdM/l69pftGGIbVjVEkz/v5ytZI=";
  };

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
  ];

  enableParallelBuilding = true;

  passthru.updateScript = directoryListingUpdater {
    inherit (finalAttrs) pname version;
    extraRegex = "(?!.*-win(32|64)).*";
    url = "https://lgames.sourceforge.io/LPairs/";
  };

  meta = {
    description = "Matching the pairs - a typical Memory Game";
    homepage = "http://lgames.sourceforge.net/LPairs/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lpairs2";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
