{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  certifi,
  chardet,
  fetchzip,
  idna,
  rel,
  urllib3,
}:
buildKodiAddon rec {
  pname = "requests";
  version = "2.31.0";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-05BSD5aoN2CTnjqaSKYMb93j5nIfLvpJHyeQsK++sTw=";
  };

  propagatedBuildInputs = [
    certifi
    chardet
    idna
    urllib3
  ];

  namespace = "script.module.requests";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.requests";
    };
  };

  meta = {
    description = "Python HTTP for Humans";
    homepage = "http://python-requests.org";
    license = lib.licenses.asl20;
    teams = [ lib.teams.kodi ];
  };
}
