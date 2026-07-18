{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  rel,
  tinyxml,
  udev,
}:
buildKodiBinaryAddon rec {
  pname = namespace;
  version = "21.1.23";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    sha256 = "sha256-ADkXvbTsx4xMUiu90hvHIMvpAF0FQ2HNkKDX/E/tRok=";
  };

  extraBuildInputs = [
    tinyxml
    udev
  ];

  namespace = "peripheral.joystick";

  meta = {
    description = "Binary addon for raw joystick input";
    homepage = "https://github.com/xbmc/peripheral.joystick";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
