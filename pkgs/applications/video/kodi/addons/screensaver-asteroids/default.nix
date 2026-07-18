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
  pname = "screensaver-asteroids";
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-cepo7amJn6y1J9hVSt35VgOz/ixT7l/UfjtmHOajBrw=";
  };

  extraBuildInputs = [
    glm
    libGL
  ];

  extraNativeBuildInputs = [ pkg-config ];
  namespace = "screensaver.asteroids";

  meta = {
    description = "Screensaver that plays Asteroids";
    homepage = "https://github.com/xbmc/screensaver.asteroids";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
