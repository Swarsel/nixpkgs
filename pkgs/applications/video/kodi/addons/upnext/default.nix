{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "upnext";
  version = "1.1.9+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-oNUk80MEzK6Qssn1KjT6psPTazISRoUif1IMo+BKJxo=";
  };

  namespace = "service.upnext";

  passthru = {
    pythonPath = "resources/lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.upnext";
    };
  };

  meta = {
    description = "Up Next - Proposes to play the next episode automatically";
    homepage = "https://github.com/im85288/service.upnext";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
