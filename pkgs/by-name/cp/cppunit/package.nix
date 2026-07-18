{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cppunit";
  version = "1.15.1";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/cppunit-${finalAttrs.version}.tar.gz";
    sha256 = "19qpqzy66bq76wcyadmi3zahk5v1ll2kig1nvg96zx9padkcdic9";
  };

  # Avoid blanket -Werror to evade build failures on less
  # tested compilers.
  configureFlags = [ "--disable-werror" ];

  meta = {
    description = "C++ unit testing framework";
    homepage = "https://freedesktop.org/wiki/Software/cppunit/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "DllPlugInTester";
  };
})
