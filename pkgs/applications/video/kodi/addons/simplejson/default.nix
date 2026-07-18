{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:

buildKodiAddon rec {
  pname = "simplejson";
  version = "3.19.1+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-RJy75WAr0XmXnSrPjqKhFjWJnWo3c5IEtUGumcE/mRo=";
  };

  namespace = "script.module.simplejson";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.simplejson";
    };
  };

  meta = {
    description = "Simple, fast, extensible JSON encoder/decoder for Python";
    homepage = "https://github.com/simplejson/simplejson";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
