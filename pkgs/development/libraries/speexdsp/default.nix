{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fftw,
  pkg-config,
  withFftw3 ? (!stdenv.hostPlatform.isMinGW),
}:

stdenv.mkDerivation rec {
  pname = "speexdsp";
  version = "1.2.1";

  src = fetchurl {
    url = "https://downloads.xiph.org/releases/speex/${pname}-${version}.tar.gz";
    sha256 = "sha256-jHdzQ+SmOZVpxyq8OKlbJNtWiCyD29tsZCSl9K61TT0=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  patches = [ ./build-fix.patch ];
  postPatch = "sed '3i#include <stdint.h>' -i ./include/speex/speexdsp_config_types.h.in";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = lib.optionals withFftw3 [ fftw ];

  configureFlags =
    lib.optionals withFftw3 [ "--with-fft=gpl-fftw3" ]
    ++ lib.optional stdenv.hostPlatform.isAarch64 "--disable-neon";

  meta = {
    description = "Open Source/Free Software patent-free audio compression format designed for speech";
    homepage = "https://www.speex.org/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };
}
