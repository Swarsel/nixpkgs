{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  SDL_mixer,
  copyDesktopItems,
  libGL,
  libGLU,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnujump";
  version = "1.0.8";

  src = fetchurl {
    url = "mirror://gnu/gnujump/gnujump-${finalAttrs.version}.tar.gz";
    sha256 = "05syy9mzbyqcfnm0hrswlmhwlwx54f0l6zhcaq8c1c0f8dgzxhqk";
  };

  patches = [ ./fix-c23-prototypes.patch ];
  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    libGL
    libGLU
    SDL
    SDL_image
    SDL_mixer
  ];

  env.NIX_LDFLAGS = "-lm";

  postInstall = ''
    install -Dm644 ${./gnujump.png} $out/share/icons/hicolor/32x32/apps/gnujump.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ArcadeGame"
      ];

      comment = "Jump up the tower to survive";
      desktopName = "GNUjump";
      exec = "gnujump";
      icon = "gnujump";
      name = "gnujump";
    })
  ];

  meta = {
    description = "Clone of the simple yet addictive game Xjump";

    longDescription = ''
      The goal in this game is to jump to the next floor trying not to fall
      down. As you go upper in the Falling Tower the floors will fall faster.
      Try to survive longer get upper than anyone. It might seem too simple but
      once you've tried you'll realize how addictive this is.
    '';

    homepage = "https://jump.gnu.sinusoid.es/index.php?title=Main_Page";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
    mainProgram = "gnujump";
  };
})
