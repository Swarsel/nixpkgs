{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "somafm";
  version = "2.0.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/plugin.audio.somafm/plugin.audio.somafm-${version}.zip";
    sha256 = "sha256-auPLm7QFabU4tXJPjTl17KpE+lqWM2Edbd2HrXPRx40=";
  };

  namespace = "plugin.audio.somafm";

  passthru = {
    pythonPath = "resources/lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.somafm";
    };
  };

  meta = {
    description = "SomaFM addon for Kodi";
    homepage = "https://github.com/Soma-FM-Kodi-Add-On/plugin.audio.somafm";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
