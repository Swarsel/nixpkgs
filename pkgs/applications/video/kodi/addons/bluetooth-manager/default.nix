{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
}:
buildKodiAddon rec {
  pname = "bluetooth-manager";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "wastis";
    repo = "BluetoothManager";
    tag = "v${version}";
    hash = "sha256-hWNi2hm5FmkRPamxMSHF3WfQ+2V+qQzkkTJWuqazbAc=";
  };

  namespace = "script.bluetooth.man";

  meta = {
    description = "Addon that allows to manage bluetooth devices from within a Linux based Kodi";
    homepage = "https://github.com/wastis/BluetoothManager";
    license = lib.licenses.gpl3Plus;
    maintainers = lib.teams.kodi.members;
    platforms = lib.platforms.all;
  };
}
