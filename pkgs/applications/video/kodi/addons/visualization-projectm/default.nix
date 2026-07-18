{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  glm,
  libGL,
  pkg-config,
  projectm_3,
  rel,
}:

buildKodiBinaryAddon rec {
  pname = "visualization-projectm";
  version = "21.0.3";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-J3RtVl+hO8DspLyF2KAVMLDIJBiEb0bKosKhJyKy9hk=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
    projectm_3
  ];

  namespace = "visualization.projectm";

  meta = {
    description = "Projectm visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.projectm";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
