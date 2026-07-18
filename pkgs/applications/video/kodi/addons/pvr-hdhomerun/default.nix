{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  jsoncpp,
  libhdhomerun,
  rel,
}:
buildKodiBinaryAddon rec {
  pname = "pvr-hdhomerun";
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "kodi-pvr";
    repo = "pvr.hdhomerun";
    rev = "${version}-${rel}";
    sha256 = "sha256-wgKMt3ufvOh08nwZTGvDGoJ0U+aUzSWJptCNRiRW4B0=";
  };

  extraBuildInputs = [
    jsoncpp
    libhdhomerun
  ];

  namespace = "pvr.hdhomerun";

  meta = {
    description = "Kodi's HDHomeRun PVR client addon";
    homepage = "https://github.com/kodi-pvr/pvr.hdhomerun";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
