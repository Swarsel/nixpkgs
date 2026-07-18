{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "six";
  version = "1.16.0+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-d6BNpnTg6K7NPX3uWp5X0rog33C+B7YoAtLH/CrUYno=";
  };

  namespace = "script.module.six";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.six";
    };
  };

  meta = {
    description = "Python 2 and 3 compatibility utilities";
    homepage = "https://pypi.org/project/six/";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
