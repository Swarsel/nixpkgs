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
  pname = "visualization-waveform";
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-RiFPR0nlyrnHzHBosvU+obbdtHXjdgMtxscQTcQ7kLw=";
  };

  propagatedBuildInputs = [ glm ];

  extraBuildInputs = [
    pkg-config
    libGL
  ];

  namespace = "visualization.waveform";

  meta = {
    description = "Waveform visualization for kodi";
    homepage = "https://github.com/xbmc/visualization.waveform";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
