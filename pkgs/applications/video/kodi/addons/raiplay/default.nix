{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  inputstreamhelper,
  plugin-cache,
  rel,
}:

buildKodiAddon rec {
  pname = "raiplay";
  version = "4.1.2";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-9aR1kkl+0+nhP0bOTnaKCgSfuPvJzX5TWHU0WJZIvSM=";
  };

  propagatedBuildInputs = [
    plugin-cache
    inputstreamhelper
  ];

  namespace = "plugin.video.raitv";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.raiplay";
    };
  };

  meta = {
    description = "Live radio and TV channels, latest 7 days of programming, broadcast archive, news";
    homepage = "https://github.com/maxbambi/plugin.video.raitv/";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.kodi ];
  };
}
