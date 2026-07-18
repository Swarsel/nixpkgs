{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  inputstream-adaptive,
  inputstream-ffmpegdirect,
  inputstream-rtmp,
  pugixml,
  rel,
  xz,
  zlib,
}:

buildKodiBinaryAddon rec {
  pname = "pvr-iptvsimple";
  version = "21.10.2";

  src = fetchFromGitHub {
    owner = "kodi-pvr";
    repo = "pvr.iptvsimple";
    rev = "${version}-${rel}";
    sha256 = "sha256-bw0rAEn8R44n5Nzc9ni6IGaG/Bxry6GSyWcT6BdgLz8=";
  };

  propagatedBuildInputs = [
    inputstream-adaptive
    inputstream-ffmpegdirect
    inputstream-rtmp
  ];

  extraBuildInputs = [
    xz
    pugixml
    zlib
  ];

  namespace = "pvr.iptvsimple";

  meta = {
    description = "Kodi's IPTV Simple client addon";
    homepage = "https://github.com/kodi-pvr/pvr.iptvsimple";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
