{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftwFloat,
  obs-studio,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "waveform";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "phandasm";
    repo = "waveform";
    rev = "v${version}";
    hash = "sha256-Bg1n1yV4JzNFEXFNayNa1exsSZhmRJ0RLHDjLWmqGZE=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace \
      src/source.hpp src/source.cpp src/source_generic.cpp \
      src/source_avx2.cpp src/source_avx.cpp \
      --replace circlebuf deque
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    obs-studio
    fftwFloat
  ];

  postFixup = ''
    mkdir -p $out/lib $out/share/obs/obs-plugins
    mv $out/${pname}/bin/64bit $out/lib/obs-plugins
    mv $out/${pname}/data $out/share/obs/obs-plugins/${pname}
    rm -rf $out/${pname}
  '';

  meta = {
    description = "Audio spectral analysis plugin for OBS";
    homepage = "https://github.com/phandasm/waveform";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    # Hard coded x86_64 support
    platforms = [ "x86_64-linux" ];
  };
}
