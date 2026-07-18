{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
}:

buildKodiAddon rec {
  pname = "xbmcswift2";
  version = "19.0.7";

  src = fetchFromGitHub {
    owner = "XBMC-Addons";
    repo = namespace;
    rev = version;
    sha256 = "sha256-Z+rHz3wncoNvV1pwhRzJFB/X0H6wdfwg88otVh27wg8=";
  };

  namespace = "script.module.xbmcswift2";

  passthru = {
    pythonPath = "lib";
  };

  meta = {
    description = "Framework to ease development of Kodi addons";
    homepage = "https://github.com/XBMC-Addons/script.module.xbmcswift2";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.kodi ];
  };
}
