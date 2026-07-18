{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
  six,
}:

buildKodiAddon rec {
  pname = "websocket";
  version = "1.6.4";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-1Wy+hxB059UoZnQlncytVT3sQ07dYAhNRnW3/QVD4ZE=";
  };

  propagatedBuildInputs = [
    six
  ];

  namespace = "script.module.websocket";

  passthru = {
    pythonPath = "lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.websocket";
    };
  };

  meta = {
    description = "WebSocket client for Python";
    homepage = "https://github.com/websocket-client/websocket-client";
    license = lib.licenses.lgpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
