{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  SDL_gfx,
  SDL_image,
  SDL_mixer,
  autoreconfHook,
  copyDesktopItems,
  imagemagick,
  libjpeg,
  libpng,
  libvorbis,
  makeDesktopItem,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "freedroid";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "ReinhardPrix";
    repo = "FreedroidClassic";
    rev = "release-${version}";
    sha256 = "027wns25nyyc8afyhyp5a8wn13x9nlzmnqzqyyma1055xjy5imis";
  };

  postPatch = ''
    touch NEWS
  '';

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    autoreconfHook
  ];

  buildInputs = [
    SDL
    SDL_image
    SDL_gfx
    SDL_mixer
    libjpeg
    libpng
    libvorbis
    zlib
  ];

  # DOes not build on -std=c23 due to `bool` collision.
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/32x32/apps
    convert graphics/paraicon.bmp $out/share/icons/hicolor/32x32/apps/freedroid.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ArcadeGame"
      ];

      comment = "A clone of the classic game 'Paradroid' on Commodore 64";
      desktopName = "Freedroid Classic";
      exec = pname;
      icon = pname;
      name = pname;
    })
  ];

  meta = {
    description = "Clone of the classic game 'Paradroid' on Commodore 64";
    homepage = "https://github.com/ReinhardPrix/FreedroidClassic";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ iblech ];
    platforms = lib.platforms.unix;
    mainProgram = "freedroid";
    # Builds but fails to render to the screen at runtime.
    broken = stdenv.hostPlatform.isDarwin;
  };
}
