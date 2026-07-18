{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  SDL_mixer,
  SDL_ttf,
  copyDesktopItems,
  imagemagick,
  lua5_1,
  makeDesktopItem,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "fish-fillets-ng";
  version = "1.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/fillets/fillets-ng-${version}.tar.gz";
    sha256 = "1nljp75aqqb35qq3x7abhs2kp69vjcj0h1vxcpdyn2yn2nalv6ij";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    SDL
    lua5_1
    SDL_mixer
    SDL_image
    SDL_ttf
  ];

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  # pass in correct sdl-config for cross builds
  env.SDL_CONFIG = lib.getExe' (lib.getDev SDL) "sdl-config";

  postInstall = ''
    mkdir -p $out/share/games/fillets-ng
    tar -xf ${data} -C $out/share/games/fillets-ng --strip-components=1
    mkdir -p $out/share/icons/hicolor/32x32/apps
    magick ${./icon.xpm} $out/share/icons/hicolor/32x32/apps/fish-fillets-ng.png
  '';

  data = fetchurl {
    sha256 = "169p0yqh2gxvhdilvjc2ld8aap7lv2nhkhkg4i1hlmgc6pxpkjgh";
    url = "mirror://sourceforge/fillets/fillets-ng-data-${version}.tar.gz";
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "LogicGame"
      ];

      comment = "Puzzle game about witty fish saving the world sokoban-style";
      desktopName = "Fish Fillets";
      exec = "fillets";
      icon = "fish-fillets-ng";
      name = "fish-fillets-ng";
    })
  ];

  meta = {
    description = "Puzzle game";
    homepage = "https://fillets.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "fillets";
  };
}
