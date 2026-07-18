{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_mixer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "barrage";
  version = "1.0.7";

  src = fetchurl {
    url = "mirror://sourceforge/lgames/barrage-${finalAttrs.version}.tar.gz";
    hash = "sha256-cGYrG7A4Ffh51KyR+UpeWu7A40eqxI8g4LefBIs18kg=";
  };

  postPatch = ''
    substituteInPlace src/main.c \
      --replace-fail "void refresh_screen()" "void refresh_screen(SDL_Surface *screen)"
  '';

  buildInputs = [
    SDL
    SDL_mixer
  ];

  hardeningDisable = [ "format" ];

  meta = {
    inherit (SDL.meta) platforms;
    description = "Destructive action game";
    homepage = "https://lgames.sourceforge.io/Barrage/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    mainProgram = "barrage";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
