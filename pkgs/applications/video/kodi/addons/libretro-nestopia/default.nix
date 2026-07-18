{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libretro,
  nestopia,
  rel,
}:

buildKodiBinaryAddon rec {
  pname = "libretro-nestopia";
  version = "1.52.0.41";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = "game.libretro.nestopia";
    rev = "${version}-${rel}";
    sha256 = "sha256-DmBO+HcfIBcz7p16dND09iwXWeObtU/doo/mJ0IZGGg=";
  };

  propagatedBuildInputs = [
    libretro
  ];

  extraBuildInputs = [ nestopia ];

  extraCMakeFlags = [
    "-DNESTOPIA_LIB=${nestopia}/lib/retroarch/cores/nestopia_libretro.so"
  ];

  namespace = "game.libretro.nestopia";

  meta = {
    description = "Nintendo - NES / Famicom (Nestopia UE) GameClient for Kodi";
    homepage = "https://github.com/kodi-game/game.libretro.nestopia";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
