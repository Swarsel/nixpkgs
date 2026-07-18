{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rlog";
  version = "1.4";

  src = fetchurl {
    url = "http://rlog.googlecode.com/files/rlog-${finalAttrs.version}.tar.gz";
    sha256 = "0y9zg0pd7vmnskwac1qdyzl282z7kb01nmn57lsg2mjdxgnywf59";
  };

  meta = {
    description = "C++ logging library used in encfs";
    homepage = "https://www.arg0.net/rlog";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
  };
})
