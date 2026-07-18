{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  dateutil,
  fetchzip,
  rel,
  trakt-module,
}:
buildKodiAddon rec {
  pname = "trakt";
  version = "3.8.2";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-75neHPVWpHhzMIOfNFvvX/Xqy3n1DO3SGg16zv/r9dU=";
  };

  propagatedBuildInputs = [
    dateutil
    trakt-module
  ];

  namespace = "script.trakt";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.trakt";
    };
  };

  meta = {
    description = "Trakt.tv movie and TV show scrobbler for Kodi";
    homepage = "https://kodi.wiki/view/Add-on:Trakt";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
