{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:
buildKodiAddon rec {
  pname = "routing";
  version = "0.2.3+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-piPmY8Q3NyIeImmkYhDwmQhBiwwcV0X532xV1DogF+I=";
  };

  namespace = "script.module.routing";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.routing";
    };
  };

  meta = {
    description = "Routing module for kodi plugins";
    homepage = "https://github.com/tamland/kodi-plugin-routing";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
