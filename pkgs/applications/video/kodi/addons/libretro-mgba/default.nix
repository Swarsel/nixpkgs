{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libretro,
  mgba,
}:

buildKodiBinaryAddon rec {
  pname = "kodi-libretro-mgba";
  version = "0.10.0.35";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.mgba";
    rev = "${version}-Matrix";
    sha256 = "sha256-lxpj6Y34apYcE22q4W3Anhigp79r4RgiJ36DbES1kzU=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ mgba ];

  extraCMakeFlags = [
    "-DMGBA_LIB=${mgba}/lib/retroarch/cores/mgba_libretro.so"
  ];

  namespace = "game.libretro.mgba";

  meta = {
    description = "mGBA for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.mgba";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
