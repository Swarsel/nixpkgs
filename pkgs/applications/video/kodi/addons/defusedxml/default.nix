{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "defusedxml";
  version = "0.6.0+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-jSl7lbFqR6hjZhHzxY69hDbs84LY3B5RYKzXnHou0Qg=";
  };

  namespace = "script.module.defusedxml";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.defusedxml";
    };
  };

  meta = {
    description = "Defusing XML bombs and other exploits";
    homepage = "https://github.com/tiran/defusedxml";
    license = lib.licenses.psfl;
    teams = [ lib.teams.kodi ];
  };
}
