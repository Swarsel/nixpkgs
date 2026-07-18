{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:
buildKodiAddon rec {
  pname = "chardet";
  version = "5.1.0";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-cIQIX6LVAoGf1sBRKWonXJd3XYqGOa5WIUttabV0HeU=";
  };

  namespace = "script.module.chardet";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.chardet";
    };
  };

  meta = {
    description = "Universal encoding detector";
    homepage = "https://github.com/Freso/script.module.chardet";
    license = lib.licenses.lgpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
