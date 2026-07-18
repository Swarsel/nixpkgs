{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  inputstreamhelper,
  rel,
  requests,
  simplecache,
}:

buildKodiAddon rec {
  pname = "skyvideoitalia";
  version = "1.0.4";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-ciLtqT++6bn7la4xRVvlRwzbbUUUPN5WU35rJpR4l+w=";
  };

  propagatedBuildInputs = [
    requests
    inputstreamhelper
    simplecache
  ];

  namespace = "plugin.video.skyvideoitalia";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.skyvideoitalia";
    };
  };

  meta = {
    description = "Show video content from the website of Sky Italia (video.sky.it). News, sport, entertainment and much more";
    homepage = "https://www.github.com/nixxo/plugin.video.skyvideoitalia";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
