{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  gw,
  libretro,
  rel,
}:

buildKodiBinaryAddon rec {
  pname = "libretro-gw";
  version = "1.6.3.34";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.gw";
    rev = "${version}-${rel}";
    hash = "sha256-HYXR3cEjbdKgKy42nq36Ii3UyxRVuQVROQjyaxSp5Ro=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ gw ];

  extraCMakeFlags = [
    "-DGW_LIB=${gw}/lib/retroarch/cores/gw_libretro.so"
  ];

  namespace = "game.libretro.gw";

  meta = {
    description = "Game and Watch for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.gw";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
