{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
  requests,
  routing,
}:

buildKodiAddon rec {
  pname = "media.ccc.de";
  version = "0.3.0+matrix.1";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/plugin.video.media-ccc-de/plugin.video.media-ccc-de-${version}.zip";
    hash = "sha256-T8J2HtPVDfaPU0gZEa0xVBzwjNInxkRFCCSxS53QhmU=";
  };

  propagatedBuildInputs = [
    requests
    routing
  ];

  namespace = "plugin.video.media-ccc-de";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.mediacccde";
    };
  };

  meta = {
    description = "media.ccc.de for Kodi";
    homepage = "https://github.com/voc/plugin.video.media-ccc-de/";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
