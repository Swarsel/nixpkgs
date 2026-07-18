{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:
buildKodiAddon rec {
  pname = "typing_extensions";
  version = "4.7.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-bCGPl5fGVyptCenpNXP/Msi7hu+UdtZd2ms7MfzbsbM=";
  };

  namespace = "script.module.typing_extensions";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.typing_extensions";
    };
  };

  meta = {
    description = "Python typing extensions";
    homepage = "https://github.com/python/typing/tree/master/typing_extensions";
    license = lib.licenses.psfl;
    teams = [ lib.teams.kodi ];
  };
}
