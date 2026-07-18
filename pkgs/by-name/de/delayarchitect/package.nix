{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  freetype,
  gcc-unwrapped,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "delayarchitect";
  version = "0-unstable-2022-01-16";

  src = fetchFromGitHub {
    owner = "jpcima";
    repo = "DelayArchitect";
    rev = "5abf4dfb7f92ba604d591a2c388d2d69a9055fe3";
    hash = "sha256-LoK2pYPLzyJF7tDJPRYer6gKHNYzvFvX/d99TuOPECo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
    libxext
    libxrandr
    libxinerama
    libxcursor
    freetype
    alsa-lib
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${gcc-unwrapped}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${gcc-unwrapped}/bin/gcc-ranlib"
    "-DCMAKE_NM=${gcc-unwrapped}/bin/gcc-nm"
  ];

  installPhase = ''
    mkdir -p $out/lib/vst3
    cd DelayArchitect_artefacts/Release
    cp -r VST3/Delay\ Architect.vst3 $out/lib/vst3
  '';

  meta = {
    description = "Visual, musical editor for delay effects";
    homepage = "https://github.com/jpcima/DelayArchitect";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.all;
  };
}
