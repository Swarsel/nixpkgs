{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libretro,
  snes9x,
}:

buildKodiBinaryAddon rec {
  pname = "kodi-libretro-snes9x";
  version = "1.61.0.34";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.snes9x";
    rev = "${version}-Matrix";
    sha256 = "sha256-LniZf8Gae4+4Rgc9OGhMCkOI3IA7CPjVrN/gbz9te38=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ snes9x ];

  extraCMakeFlags = [
    "-DSNES9X_LIB=${snes9x}/lib/retroarch/cores/snes9x_libretro.so"
  ];

  namespace = "game.libretro.snes9x";

  meta = {
    description = "Snes9X GameClient for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.snes9x";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
