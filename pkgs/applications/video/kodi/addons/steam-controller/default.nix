{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libusb1,
}:
buildKodiBinaryAddon rec {
  pname = namespace;
  version = "20.0.2";

  src = fetchFromGitHub {
    owner = "kodi-game";
    repo = namespace;
    rev = "b3174673c6feb34325975b6c007581c39bf3e4a5";
    sha256 = "sha256-Q+eJfbD4NpAPANm9Mx9/pD29L5tdS4gxhQqNufufYdw=";
  };

  extraBuildInputs = [ libusb1 ];
  namespace = "peripheral.steamcontroller";

  meta = {
    description = "Binary addon for steam controller";
    homepage = "https://github.com/kodi-game/peripheral.steamcontroller";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
