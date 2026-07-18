{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:
buildKodiAddon rec {
  pname = "myconnpy";
  version = "8.0.33";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-NlLMq9RAdWu8rVsMc0FDe1HmQiVp5T7iBXbIH7HB5bI=";
  };

  namespace = "script.module.myconnpy";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.myconnpy";
    };
  };

  meta = {
    description = "MySQL Connector/Python";
    homepage = "http://dev.mysql.com/doc/connector-python/en/index.html";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
