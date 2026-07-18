{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "future";
  version = "1.0.0+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-BsDgCAZuJBRBpe6EmfSynhrXS3ktQRZsEwf9CdF0VCg=";
  };

  namespace = "script.module.future";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.future";
    };
  };

  meta = {
    description = "Missing compatibility layer between Python 2 and Python 3";
    homepage = "https://python-future.org";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
