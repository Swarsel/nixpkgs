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
  pname = "visualization-spectrum";
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-8yGmZeLJ8AdT17yqYVxYbmkZ6DqhlCyblbTUzf8MhE4=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
  ];

  namespace = "visualization.spectrum";

  meta = {
    description = "Spectrum visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.spectrum";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
