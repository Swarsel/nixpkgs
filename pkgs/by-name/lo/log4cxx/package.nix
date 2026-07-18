{
  lib,
  stdenv,
  fetchurl,
  apr,
  aprutil,
  boost,
  cmake,
  cppunit,
  db,
  expat,
  libtool,
  libxml2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "log4cxx";
  version = "1.7.0";

  src = fetchurl {
    url = "mirror://apache/logging/log4cxx/${finalAttrs.version}/apache-log4cxx-${finalAttrs.version}.tar.gz";
    hash = "sha256-uUP/FwOT5M44GrTEkUOWEnv01E+4vR8OXvhFPzxNNkw=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace "\\\''${prefix}/" ""
  '';

  nativeBuildInputs = [
    libtool
    cmake
  ];

  buildInputs = [
    libxml2
    cppunit
    boost
    apr
    aprutil
    db
    expat
  ];

  meta = {
    description = "Logging framework for C++ patterned after Apache log4j";
    homepage = "https://logging.apache.org/log4cxx/index.html";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
})
