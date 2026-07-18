{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libjpeg,
  libpng,
  libx11,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxcomp";
  version = "3.5.99.16";

  src = fetchurl {
    url = "https://code.x2go.org/releases/source/nx-libs/nx-libs-${finalAttrs.version}-lite.tar.gz";
    sha256 = "1m3z9w3h6qpgk265xf030w7lcs181jgw2cdyzshb7l97mn1f7hh2";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libjpeg
    libpng
    libx11
    zlib
  ];

  enableParallelBuilding = true;

  preAutoreconf = ''
    cd nxcomp/
    sed -i 's|/src/.libs/libXcomp.a|/src/.libs/libXcomp.la|' test/Makefile.am
  '';

  meta = {
    description = "NX compression library";
    homepage = "http://wiki.x2go.org/doku.php/wiki:libs:nx-libs";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
