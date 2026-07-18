{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  flex,
  glib,
  gtk2,
  makeDesktopItem,
  pkg-config,
  python3,
  readline,
}:

stdenv.mkDerivation rec {
  pname = "gnubg";
  version = "1.08.003";

  src = fetchurl {
    url = "mirror://gnu/gnubg/gnubg-release-${version}-sources.tar.gz";
    hash = "sha256-b32WmxPP/3hvupD/jMXl1WS5f08Kppr+Tzg48YxEWXk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    python3
    flex
    glib
  ];

  buildInputs = [
    gtk2
    readline
  ];

  configureFlags = [
    "--with-gtk"
    "--with--board3d"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "GTK"
        "StrategyGame"
      ];

      comment = meta.description;
      desktopName = "GNU Backgammon";
      exec = pname;
      genericName = "Backgammon";
      icon = pname;
      name = pname;
    })
  ];

  meta = {
    description = "World class backgammon application";
    homepage = "https://www.gnu.org/software/gnubg/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
