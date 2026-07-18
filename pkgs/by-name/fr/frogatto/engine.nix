{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  boost,
  cairo,
  glew,
  glm,
  icu,
  libvpx,
  pkg-config,
  which,
  zlib,
}:

stdenv.mkDerivation {
  pname = "anura-engine";
  version = "unstable-2023-02-27";

  src = fetchFromGitHub {
    owner = "anura-engine";
    repo = "anura";
    rev = "65d85b6646099db1d5cd25d31321bb434a3f94f1";
    sha256 = "sha256-hb4Sn7uI+eXLaGb4zkEy4w+ByQJ6FqkoMUYFsyiFCeE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    which
    pkg-config
  ];

  buildInputs = [
    boost
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    glew
    zlib
    icu
    cairo
    libvpx
    glm
  ];

  env.CXXFLAGS = "-DGLM_ENABLE_EXPERIMENTAL -Wno-error=deprecated-declarations";

  installPhase = ''
    mkdir -p $out/bin $out/share/frogatto
    cp -ar data images modules $out/share/frogatto/
    cp -a anura $out/bin/frogatto
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Game engine used by Frogatto";
    homepage = "https://github.com/anura-engine/anura";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ astro ];
    platforms = lib.platforms.linux;
  };
}
