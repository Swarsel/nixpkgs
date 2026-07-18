{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  inputstream-adaptive,
  inputstreamhelper,
  requests,
}:

buildKodiAddon rec {
  pname = "youtube";
  version = "7.4.4";

  src = fetchFromGitHub {
    owner = "anxdpanic";
    repo = "plugin.video.youtube";
    rev = "v${version}";
    hash = "sha256-epDKZhITQAv3bpS7CGN2Rj35/AamyZo5yzhkfu72ipw=";
  };

  propagatedBuildInputs = [
    requests
    inputstream-adaptive
    inputstreamhelper
  ];

  namespace = "plugin.video.youtube";

  passthru = {
    pythonPath = "resources/lib";
  };

  meta = {
    description = "YouTube is one of the biggest video-sharing websites of the world";
    homepage = "https://github.com/anxdpanic/plugin.video.youtube";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
