{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  rel,
  tinyxml,
}:

buildKodiBinaryAddon rec {
  pname = "libretro";
  version = "20.1.0";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro";
    rev = "${version}-${rel}";
    sha256 = "sha256-RwaLGAJt13PLKy45HU64TvQFyY532WWq2YX34Eyu+6o=";
  };

  extraBuildInputs = [ tinyxml ];
  namespace = "game.libretro";

  meta = {
    description = "Libretro wrapper for Kodi's Game API";
    homepage = "https://github.com/kodi-game/game.libretro";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
