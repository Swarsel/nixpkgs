{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  dateutil,
  fetchzip,
  rel,
  requests,
  xbmcswift2,
}:

buildKodiAddon rec {
  pname = "arteplussept";
  version = "1.4.4";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    hash = "sha256-jFIcLhglfOqkFLtlIJKB1o++mWfnpWKS3w1wD0S3+CE=";
  };

  propagatedBuildInputs = [
    dateutil
    requests
    xbmcswift2
  ];

  namespace = "plugin.video.arteplussept";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.arteplussept";
    };
  };

  meta = {
    description = "Watch videos available on Arte+7";
    homepage = "https://github.com/thomas-ernest/plugin.video.arteplussept";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
