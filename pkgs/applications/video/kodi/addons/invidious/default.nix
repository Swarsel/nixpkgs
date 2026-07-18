{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  infotagger,
  inputstream-adaptive,
  inputstreamhelper,
  rel,
  requests,
}:

buildKodiAddon rec {
  pname = "invidious";
  version = "0.2.6";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/plugin.video.invidious/plugin.video.invidious-${version}+nexus.0.zip";
    sha256 = "sha256-XnlnhvtHMh4uQTupW/SSOmaEV8xZrL61/6GoRpyKR0o=";
  };

  propagatedBuildInputs = [
    infotagger
    requests
    inputstream-adaptive
    inputstreamhelper
  ];

  namespace = "plugin.video.invidious";

  passthru = {
    pythonPath = "resources/lib";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.invidious";
    };
  };

  meta = {
    description = "Privacy-friendly way of watching YouTube content";
    homepage = "https://github.com/petterreinholdtsen/kodi-invidious-plugin";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
