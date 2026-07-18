{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
  requests,
}:
buildKodiAddon rec {
  pname = "requests-cache";
  version = "0.5.2+matrix.2";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-6M/v/ghS2TnSZhG8bREjxfEfcfLOmvA6hgsa7JUk9Dk=";
  };

  propagatedBuildInputs = [
    requests
  ];

  namespace = "script.module.requests-cache";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.requests-cache";
    };
  };

  meta = {
    description = "Persistent cache for requests library";
    homepage = "https://github.com/reclosedev/requests-cache";
    license = lib.licenses.bsd2;
    teams = [ lib.teams.kodi ];
  };
}
