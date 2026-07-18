{
  lib,
  addonUpdateScript,
  arrow,
  buildKodiAddon,
  fetchzip,
  rel,
  requests,
  six,
}:
buildKodiAddon rec {
  pname = "trakt-module";
  version = "4.4.0+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-6JIAQwot5VZ36gvQym88BD/e/mSyS8WO8VqkPn2GcqY=";
  };

  propagatedBuildInputs = [
    requests
    six
    arrow
  ];

  namespace = "script.module.trakt";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.trakt-module";
    };
  };

  meta = {
    description = "Python trakt.py library packed for Kodi";
    homepage = "https://github.com/Razzeee/script.module.trakt";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
