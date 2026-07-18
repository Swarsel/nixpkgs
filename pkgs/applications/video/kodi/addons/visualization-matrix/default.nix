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
  pname = "visualization-matrix";
  version = "20.2.0";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-tojzPqt6VMccveqnhkl0yXS+/fLdxotmQO3jdtYlkFk=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
  ];

  namespace = "visualization.matrix";

  meta = {
    description = "Matrix visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.matrix";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
