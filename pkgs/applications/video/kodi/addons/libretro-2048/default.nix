{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libretro,
  twenty-fortyeight,
}:

buildKodiBinaryAddon rec {
  pname = "libretro-2048";
  version = "1.0.0.136";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.2048";
    rev = "${version}-Nexus";
    hash = "sha256-cIo56ZGansBlAj6CFw51UOYJUivN9n1qhVTWAX9c5Tc=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ twenty-fortyeight ];

  extraCMakeFlags = [
    "-D2048_LIB=${twenty-fortyeight}/lib/retroarch/cores/2048_libretro.so"
  ];

  namespace = "game.libretro.2048";

  meta = {
    description = "2048 GameClient for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.2048";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ kazenyuk ];
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
