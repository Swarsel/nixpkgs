{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  glm,
  jsoncpp,
  libGL,
  pkg-config,
  rel,
}:

buildKodiBinaryAddon rec {
  pname = "visualization-shadertoy";
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-M70WQL4BqFI4LMFLBXlupuXxRkbTqA0OocYlCbY28VQ=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
    jsoncpp
  ];

  namespace = "visualization.shadertoy";

  meta = {
    description = "Shadertoy visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.shadertoy";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
