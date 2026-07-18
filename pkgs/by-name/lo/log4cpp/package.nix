{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "log4cpp";
  version = "1.1.4";

  src = fetchurl {
    url = "mirror://sourceforge/log4cpp/log4cpp-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-aWETZZ5CZUBiUnSoslEFLMBDBtjuXEKgx2OfOcqQydY=";
  };

  enableParallelBuilding = true;

  meta = {
    description = "Logging framework for C++ patterned after Apache log4j";
    homepage = "https://log4cpp.sourceforge.net/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "log4cpp-config";
  };
})
