{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  glm,
  libGL,
  pkg-config,
  rel,
}:

buildKodiBinaryAddon rec {
  pname = "visualization-goom";
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-TGSYSrQLFrjbp+UMQ14f5sb8thePFZaSH7x/ckLIoqw=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
  ];

  namespace = "visualization.goom";

  meta = {
    description = "Goom visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.goom";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
