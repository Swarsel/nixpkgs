{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  bzip2,
  kodi,
  rel,
  zlib,
}:

buildKodiBinaryAddon rec {
  pname = "inputstream-ffmpegdirect";
  version = "21.3.8";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "inputstream.ffmpegdirect";
    rev = "${version}-${rel}";
    sha256 = "sha256-IgCSEJzu3a2un7FdiZCEVs/boxvIhSNleTPpOCljCZo=";
  };

  extraBuildInputs = [
    bzip2
    zlib
    kodi.ffmpeg
  ];

  namespace = "inputstream.ffmpegdirect";

  meta = {
    description = "InputStream Client for streams that can be opened by either FFmpeg's libavformat or Kodi's cURL";
    homepage = "https://github.com/xbmc/inputstream.ffmpegdirect/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
