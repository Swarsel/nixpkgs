{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "plugin-cache";
  version = "3.0.0";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-5QcMNmWOEw2C26OXlvAvxqDxTpjIMBhwmaIFwVgHuIU=";
  };

  namespace = "script.common.plugin.cache";

  passthru = {
    pythonPath = "resources/lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.plugin-cache";
    };
  };

  meta = {
    description = "Common plugin cache";
    homepage = "https://github.com/anxdpanic/script.common.plugin.cache";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.kodi ];
  };
}
