{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "kodi-six";
  version = "0.1.3.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-nWz5CPoE0uVsZvWjI4q6y4ZKUnraTjTXLSJ1mK4YopI=";
  };

  namespace = "script.module.kodi-six";

  passthru = {
    pythonPath = "libs";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.kodi-six";
    };
  };

  meta = {
    description = "Wrappers around Kodi Python API for seamless Python 2/3 compatibility";
    homepage = "https://github.com/romanvm/kodi.six";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.kodi ];
  };
}
