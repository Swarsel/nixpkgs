{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  openssl,
  rel,
  rtmpdump,
  zlib,
}:

buildKodiBinaryAddon rec {
  pname = "inputstream-rtmp";
  version = "21.1.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "inputstream.rtmp";
    rev = "${version}-${rel}";
    sha256 = "sha256-AkpRbYOe30dWDcflCGXxJz8Y+9bQw9ZmZF88ra2c+fc=";
  };

  extraBuildInputs = [
    openssl
    rtmpdump
    zlib
  ];

  namespace = "inputstream.rtmp";

  meta = {
    description = "Client for RTMP streams";
    homepage = "https://github.com/xbmc/inputstream.rtmp/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
