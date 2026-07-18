{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
}:
buildKodiAddon rec {
  pname = "idna";
  version = "3.10.0";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-wFS7rETO+VGeg1MxMEdb/cwVw5/TEoZF2CS3BjkxDlk=";
  };

  namespace = "script.module.idna";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.idna";
    };
  };

  meta = {
    description = "Internationalized Domain Names for Python";
    homepage = "https://github.com/Freso/script.module.idna";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.kodi ];
  };
}
