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
  pname = "visualization-starburst";
  version = "20.2.0";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-FTGyQqzRywKjywtckkP56Fc8KwF07A8WUAe0LackxSM=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
  ];

  namespace = "visualization.starburst";

  meta = {
    description = "Starburst visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.starburst";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
