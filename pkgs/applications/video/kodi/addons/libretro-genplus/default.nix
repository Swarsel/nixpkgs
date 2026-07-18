{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  genesis-plus-gx,
  libretro,
}:

buildKodiBinaryAddon rec {
  pname = "kodi-libretro-genplus";
  version = "1.7.4.35";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.genplus";
    rev = "${version}-Matrix";
    sha256 = "sha256-F3bt129lBZKlDtp7X0S0q10T9k9C2zNeHG+yIP3818Q=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ genesis-plus-gx ];

  extraCMakeFlags = [
    "-DGENPLUS_LIB=${genesis-plus-gx}/lib/retroarch/cores/genesis_plus_gx_libretro.so"
  ];

  namespace = "game.libretro.genplus";

  meta = {
    description = "Genesis Plus GX GameClient for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.genplus";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
