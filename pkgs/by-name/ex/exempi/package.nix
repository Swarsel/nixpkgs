{
  lib,
  stdenv,
  fetchurl,
  boost,
  expat,
  libiconv,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "exempi";
  version = "2.6.6";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/exempi-${version}.tar.bz2";
    sha256 = "sha256-dRO35Cw72QpY132TjGDS6Hxo+BZG58uLEtcf4zQ5HG8=";
  };

  buildInputs = [
    expat
    zlib
    boost
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"
  ]
  ++ lib.optionals (!doCheck) [
    "--enable-unittest=no"
  ];

  doCheck = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.is64bit;
  dontDisableStatic = doCheck;
  enableParallelBuilding = true;

  meta = {
    description = "Implementation of XMP (Adobe's Extensible Metadata Platform)";
    homepage = "https://libopenraw.freedesktop.org/exempi/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "exempi";
  };
}
