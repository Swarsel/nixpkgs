{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  fuse,
  libretro,
}:

buildKodiBinaryAddon rec {
  pname = "libretro-fuse";
  version = "1.6.0.34";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.fuse";
    rev = "${version}-Nexus";
    hash = "sha256-MimwEV7YD6pMshxqbKTVbLDsPmMbqSy4HPnxwmKswpc=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ fuse ];

  extraCMakeFlags = [
    "-DFUSE_LIB=${fuse}/lib/retroarch/cores/fuse_libretro.so"
  ];

  namespace = "game.libretro.fuse";

  meta = {
    description = "Sinclair - ZX Spectrum (Fuse) GameClient for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.fuse";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kazenyuk ];
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
